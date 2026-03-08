import cv2
import torch
import paho.mqtt.client as mqtt
import function.utils_rotate as utils_rotate
import function.helper as helper
from collections import Counter
import warnings
import time

warnings.filterwarnings("ignore", category=FutureWarning)
warnings.filterwarnings("ignore", category=DeprecationWarning)
warnings.filterwarnings("ignore", category=UserWarning)

# ============================
# LOAD YOLO MODELS
# ============================
yolo_LP_detect = torch.hub.load('yolov5', 'custom',
                                path='model/LP_detector_nano_61.pt',
                                force_reload=False, source='local')

yolo_license_plate = torch.hub.load('yolov5', 'custom',
                                    path='model/LP_ocr_nano_62.pt',
                                    force_reload=False, source='local')
yolo_license_plate.conf = 0.60

# ============================
# MQTT CONFIG
# ============================
MQTT_BROKER = "edbbea48be36467bb4baeea211156ed0.s1.eu.hivemq.cloud"
MQTT_PORT = 8883
MQTT_USERNAME = "nha_xe_thong_minh"
MQTT_PASSWORD = "Nhaxe123"
TOPIC_PLATE_NEW = "plate/new"

mqtt_client = mqtt.Client()
mqtt_client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)
mqtt_client.tls_set()
mqtt_client.connect(MQTT_BROKER, MQTT_PORT)
mqtt_client.loop_start()

# ============================
# CAMERA + STATES
# ============================
vid = cv2.VideoCapture(0)
MAX_SCANS = 15
temp_plates = []

# Biến kiểm soát gửi lại biển cũ
last_sent_time = {}          # { "29A12345": timestamp }
RESEND_DELAY = 60            # ví dụ: 60s = 1 phút

def send_plate_web(plate):
    mqtt_client.publish(TOPIC_PLATE_NEW, plate)
    print(f"🚀 Sent plate to web: {plate}")

print("🔍 Start scanning (Q = quit, P = pause)")
paused = False

# ============================
# MAIN LOOP
# ============================
while True:
    if not paused:
        ret, frame = vid.read()
        if not ret:
            break

        plates = yolo_LP_detect(frame, size=640)
        list_plates = plates.pandas().xyxy[0].values.tolist()
        list_read_plates = []

        for plate in list_plates:
            x1, y1, x2, y2 = map(int, plate[:4])
            crop_img = frame[y1:y2, x1:x2]
            cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 0, 225), 2)

            found = False
            for cc in range(2):
                for ct in range(2):
                    lp = helper.read_plate(
                        yolo_license_plate,
                        utils_rotate.deskew(crop_img, cc, ct)
                    )
                    if lp != "unknown" and len(lp) >= 5:
                        list_read_plates.append(lp)
                        cv2.putText(frame, lp, (x1, y1 - 10),
                                    cv2.FONT_HERSHEY_SIMPLEX, 0.9,
                                    (36, 255, 12), 2)
                        found = True
                        break
                if found:
                    break

        temp_plates.extend(list_read_plates)

        # đủ số lần quét → lấy kết quả chính xác
        if len(temp_plates) >= MAX_SCANS:
            most_common_plate, count = Counter(temp_plates).most_common(1)[0]

            now = time.time()
            last_time = last_sent_time.get(most_common_plate, 0)

            # kiểm tra delay gửi lại
            if now - last_time >= RESEND_DELAY:
                last_sent_time[most_common_plate] = now

                print(f"\n✅ Plate detected: {most_common_plate} ({count}/{MAX_SCANS})")
                send_plate_web(most_common_plate)
            else:
                print(f"⏳ Biển {most_common_plate} bị chặn (gửi lại sau {int(RESEND_DELAY - (now - last_time))}s)")

            temp_plates.clear()

        cv2.imshow('frame', cv2.resize(frame, (960, 540)))

    key = cv2.waitKey(1) & 0xFF
    if key == ord('q'):
        print("🛑 Exit.")
        break
    elif key == ord('p'):
        paused = not paused
        print("⏸ Paused." if paused else "▶ Continue...")

vid.release()
cv2.destroyAllWindows()
mqtt_client.loop_stop()
mqtt_client.disconnect()
