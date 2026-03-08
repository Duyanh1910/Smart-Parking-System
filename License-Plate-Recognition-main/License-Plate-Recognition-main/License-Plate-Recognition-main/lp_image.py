from PIL import Image
import cv2
import torch
import function.utils_rotate as utils_rotate
import function.helper as helper

# ✅ Đường dẫn ảnh
image_path = r"test_image\1.jpg"

# ✅ Tải mô hình
yolo_LP_detect = torch.hub.load('yolov5', 'custom', path='model/LP_detector.pt', force_reload=True, source='local')
yolo_license_plate = torch.hub.load('yolov5', 'custom', path='model/LP_ocr.pt', force_reload=True, source='local')
yolo_license_plate.conf = 0.60

# ✅ Đọc ảnh
img = cv2.imread(image_path)
plates = yolo_LP_detect(img, size=640)

# ✅ Phát hiện biển số
list_plates = plates.pandas().xyxy[0].values.tolist()
list_read_plates = set()

for plate in list_plates:
    flag = 0
    x1, y1, x2, y2 = int(plate[0]), int(plate[1]), int(plate[2]), int(plate[3])
    crop_img = img[y1:y2, x1:x2]
    cv2.rectangle(img, (x1, y1), (x2, y2), (0, 0, 225), 2)

    # Thử đọc biển số với các góc xoay khác nhau
    for cc in range(2):
        for ct in range(2):
            lp = helper.read_plate(yolo_license_plate, utils_rotate.deskew(crop_img, cc, ct))
            if lp != "unknown":
                list_read_plates.add(lp)
                cv2.putText(img, lp, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (36, 255, 12), 2)
                flag = 1
                break
        if flag:
            break

# ✅ Hiển thị kết quả ảnh
cv2.imshow('frame', img)
cv2.waitKey()
cv2.destroyAllWindows()

# ✅ Lưu kết quả ra file, mỗi biển số 1 dòng
with open("output.txt", "w") as f:
    for lp in list_read_plates:
        print(lp)          # In ra console
        f.write(lp + "\n") # Lưu vào file

print("Các biển số đã được lưu vào file output.txt")
