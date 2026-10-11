import mediapipe
from pynput.keyboard import Controller, Key

class Gesture_Callback:
    def __init__(self, output_generator):
        self.gesture_result = None
        self.output_image = None
        self.timestamp_ms = None
        self.output_generator = output_generator
        self.last_hand_gesture = None

    def GestureCallback(self, result, output_image, timestamp_ms):
        self.gesture_result = result
        self.output_image = output_image
        self.timestamp_ms = timestamp_ms
        
        current_gesture = "None"
        try:
            if result.gestures and len(result.gestures) > 0 and len(result.gestures[0]) > 0:
                current_gesture = result.gestures[0][0].category_name
        except Exception:
            current_gesture = "None"
            
        if current_gesture != self.last_hand_gesture and current_gesture != "None":
            print(f"Detected Gesture: {current_gesture}")
            self.output_generator.perform_action(current_gesture)
            
        self.last_hand_gesture = current_gesture

class Give_Output:
    def __init__(self):
        self.keyboard = Controller()

    def perform_action(self, gesture_name):
        if gesture_name == "Closed_Fist":
            self.keyboard.press(Key.f14); self.keyboard.release(Key.f14)   
        elif gesture_name == "Pointing_Up":
            self.keyboard.press(Key.f15); self.keyboard.release(Key.f15)   
        elif gesture_name == "Thumb_Up":
            self.keyboard.press(Key.f16); self.keyboard.release(Key.f16)   
        elif gesture_name == "Victory":
            self.keyboard.press(Key.f18); self.keyboard.release(Key.f18)   
        elif gesture_name == "Open_Palm":
            self.keyboard.press(Key.f13); self.keyboard.release(Key.f13)
        elif gesture_name == "Thumb_Down":
            self.keyboard.press(Key.f17); self.keyboard.release(Key.f17)
        elif gesture_name == "ILoveYou":
            self.keyboard.press(Key.f19); self.keyboard.release(Key.f19)
