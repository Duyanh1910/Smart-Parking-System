import torch
import cv2
import matplotlib.pyplot as plt
import os
from yolov5.utils.augmentations import letterbox

# ======================
# PATH CONFIG
# ======================
YOLOV5_DIR = r'D:\Hoc ki 4 - 1\BTL_IOT_Nha_Xe_Thong_Minh\License-Plate-Recognition-main\License-Plate-Recognition-main\License-Plate-Recognition-main\yolov5'
MODEL_PATH = r'D:\Hoc ki 4 - 1\BTL_IOT_Nha_Xe_Thong_Minh\License-Plate-Recognition-main\License-Plate-Recognition-main\License-Plate-Recognition-main\model\LP_detector.pt'
IMAGE_PATH = r'License-Plate-Recognition-main/test_image/3.jpg'

# ======================
# LOAD YOLOv5 MODEL
# ======================
yolo_LP_detect = torch.hub.load(
    YOLOV5_DIR,
    'custom',
    path=MODEL_PATH,
    source='local'
)

yolo_LP_detect.eval()
device = next(yolo_LP_detect.parameters()).device

# ======================
# LOAD IMAGE (YOLOv5 STYLE)
# ======================
img0 = cv2.imread(IMAGE_PATH)
img0 = cv2.cvtColor(img0, cv2.COLOR_BGR2RGB)

img, _, _ = letterbox(img0, new_shape=640)

img = torch.from_numpy(img).permute(2, 0, 1).unsqueeze(0)
img = img.float() / 255.0
img = img.to(device)

# ======================
# GET CORE MODEL
# ======================
core_model = yolo_LP_detect.model.model
core_model.eval()

# ======================
# HOOK C1 → C5
# ======================
layers = {
    "C1": 0,
    "C2": 1,
    "C3": 4,
    "C4": 6,
    "C5": 9
}

features = {}

def hook(name):
    def fn(m, i, o):
        features[name] = o.detach()
    return fn

for name, idx in layers.items():
    core_model.model[idx].register_forward_hook(hook(name))

# ======================
# FORWARD
# ======================
with torch.no_grad():
    _ = core_model(img)

# ======================
# VISUALIZE & SAVE
# ======================
os.makedirs("result", exist_ok=True)

for name, feat in features.items():
    f = feat[0]  # [C,H,W]

    plt.figure(figsize=(8, 8))
    for i in range(16):
        plt.subplot(4, 4, i + 1)
        plt.imshow(f[i].cpu().numpy(), cmap='gray')
        plt.axis('off')

    plt.suptitle(f"YOLOv5 LP_detector – {name} feature maps")
    plt.tight_layout()

    out_path = f"result/{name}_feature_maps.png"
    plt.savefig(out_path, dpi=200)
    plt.close()

    print(f"[OK] Saved {out_path}")

print("\nDone! Check folder: result/")
