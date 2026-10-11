import cv2
import time
import socket
import os
import sys
import ctypes
import mediapipe
from mediapipe.tasks import python as mp_tasks
from mediapipe.tasks.python import vision as mp_vision
from Mini_Functions import Gesture_Callback as GCB
from Mini_Functions import Give_Output as GO

# --- WINDOWS LIFECYCLE LOCK (AUTO-CLOSE ON GODOT EXIT) ---
if sys.platform == "win32":
    try:
        # Create a Job Object to tie this process to the parent process (Godot)
        GetCurrentProcess = ctypes.windll.kernel32.GetCurrentProcess
        SetInformationJobObject = ctypes.windll.kernel32.SetInformationJobObject
        
        # 9 stands for JobObjectExtendedLimitInformation
        # This tells Windows: "If the parent process dies, kill this process immediately."
        class JOBOBJECT_BASIC_LIMIT_INFORMATION(ctypes.Structure):
            _fields_ = [("LimitFlags", ctypes.c_uint32)]
            
        class JOBOBJECT_EXTENDED_LIMIT_INFORMATION(ctypes.Structure):
            _fields_ = [
                ("BasicLimitInformation", JOBOBJECT_BASIC_LIMIT_INFORMATION),
                ("RemainingInformation", ctypes.c_size_t * 22) 
            ]
        
        # 0x2000 is JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
        info = JOBOBJECT_EXTENDED_LIMIT_INFORMATION()
        info.BasicLimitInformation.LimitFlags = 0x2000
        
        # Assign the limit to our process group
        ctypes.windll.kernel32.AssignProcessToJobObject(None, GetCurrentProcess())
    except Exception as e:
        print(f"Lifecycle Lock Warning: {e}")

# --- NETWORK STREAMING MATRIX CONFIG ---
GODOT_IP = "127.0.0.1"
PORT_VIDEO = 4244
sock_video = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

cap = cv2.VideoCapture(1, cv2.CAP_DSHOW)
if not cap.isOpened():
    print("Warning: Could not open camera at index 1. Trying index 0...")
    cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)
    if not cap.isOpened():
        print("Critical Error: No webcam hardware discovered.")
        sys.exit() 

Output_Generator = GO()
Gesture_callback = GCB(Output_Generator)

if getattr(sys, 'frozen', False):
    CURRENT_DIR = os.path.dirname(sys.executable)
else:
    CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))

gesture_model_path = os.path.join(CURRENT_DIR, "Model", "gesture_recognizer.task")

gesture_base_options = mp_tasks.BaseOptions(
    model_asset_path=gesture_model_path, 
    delegate=mediapipe.tasks.BaseOptions.Delegate.CPU
)

GestureRecognizerOptions = mp_vision.GestureRecognizerOptions(
    base_options=gesture_base_options, 
    running_mode=mp_vision.RunningMode.LIVE_STREAM, 
    num_hands=1,
    result_callback=Gesture_callback.GestureCallback
)
GestureRecognizer = mp_vision.GestureRecognizer.create_from_options(GestureRecognizerOptions)

cap.set(cv2.CAP_PROP_FRAME_WIDTH, 320)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 240)

print(f"AI Streaming Engine active. Loading model from: {gesture_model_path}")

while True:
    ret, frame = cap.read()
    if not ret:
        break

    corrected_frame = cv2.flip(frame, 1)
    rgb_frame = cv2.cvtColor(corrected_frame, cv2.COLOR_BGR2RGB)
    mp_image = mediapipe.Image(image_format=mediapipe.ImageFormat.SRGB, data=rgb_frame)

    frame_timestamp = int(time.time() * 1000)
    GestureRecognizer.recognize_async(mp_image, frame_timestamp)

    try:
        _, encoded_img = cv2.imencode('.jpg', corrected_frame, [int(cv2.IMWRITE_JPEG_QUALITY), 50])
        bytes_data = encoded_img.tobytes()
        if len(bytes_data) < 65000:
            sock_video.sendto(bytes_data, (GODOT_IP, PORT_VIDEO))
    except Exception:
        pass

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
