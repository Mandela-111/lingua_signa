# 🧪 LinguaSigna Testing Protocol

**Zero-Error Validation Before Integration**

---

## 🎯 Testing Strategy

```
✅ ML System → ✅ Backend Server → ✅ Integration Ready
   (Isolated)     (Isolated)        (Only after both pass)
```

---

## 🧠 Part A: ML System Testing

### A1: Environment Setup
```bash
# Test Python environment
mkdir ml-testing && cd ml-testing

python -c "import tensorflow; print('✅ TensorFlow:', tensorflow.__version__)"
python -c "import mediapipe; print('✅ MediaPipe:', mediapipe.__version__)"
python -c "import cv2; print('✅ OpenCV:', cv2.__version__)"
python -c "import flask; print('✅ Flask:', flask.__version__)"
```

### A2: Hand Detection Test
**File: `test_hands.py`**
```python
import cv2
import mediapipe as mp
import numpy as np

def test_hand_detection():
    print("🧪 Testing hand detection...")
    
    hands = mp.solutions.hands.Hands(
        static_image_mode=False,
        max_num_hands=2,
        min_detection_confidence=0.7
    )
    
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("❌ No camera detected")
        return False
    
    detection_count = 0
    total_frames = 10
    
    print("👋 Show your hand to camera for 10 frames...")
    
    for i in range(total_frames):
        ret, frame = cap.read()
        if not ret:
            continue
            
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = hands.process(rgb_frame)
        
        if results.multi_hand_landmarks:
            detection_count += 1
            print(f"Frame {i+1}: ✅ Hand detected")
        else:
            print(f"Frame {i+1}: ❌ No hand")
    
    accuracy = (detection_count / total_frames) * 100
    print(f"📊 Detection Accuracy: {accuracy:.1f}%")
    
    cap.release()
    hands.close()
    
    return accuracy >= 50

if __name__ == "__main__":
    if test_hand_detection():
        print("🎉 HAND DETECTION: PASS")
    else:
        print("❌ HAND DETECTION: FAIL")
```

### A3: Translation Logic Test
**File: `test_translation.py`**
```python
class SimpleSignTranslator:
    def __init__(self):
        self.asl_words = ["Hello", "Thank you", "Please", "Sorry"]
        self.gsl_words = ["Akwaaba", "Medaase", "Mepa wo kyɛw", "Kafra"]
    
    def translate(self, hand_points, language="asl"):
        if not hand_points:
            return None
        
        import random
        words = self.asl_words if language == "asl" else self.gsl_words
        return {
            "text": random.choice(words),
            "confidence": random.uniform(0.8, 0.95),
            "language": language
        }

def test_translator():
    print("🧪 Testing translator...")
    
    translator = SimpleSignTranslator()
    mock_points = [[0.5, 0.5] for _ in range(21)]
    
    # Test ASL
    result = translator.translate(mock_points, "asl")
    assert result is not None, "Translation failed"
    assert "text" in result, "Missing text field"
    assert result["language"] == "asl", "Wrong language"
    print(f"✅ ASL: {result['text']}")
    
    # Test GSL  
    result = translator.translate(mock_points, "gsl")
    assert result["language"] == "gsl", "Wrong language"
    print(f"✅ GSL: {result['text']}")
    
    # Test no hands
    result = translator.translate(None, "asl")
    assert result is None, "Should return None"
    print("✅ No hands handled correctly")
    
    return True

if __name__ == "__main__":
    if test_translator():
        print("🎉 TRANSLATION: PASS")
    else:
        print("❌ TRANSLATION: FAIL")
```

### A4: AI Server Test
**File: `test_ai_api.py`**
```python
import requests
import base64
import numpy as np
import cv2

def test_ai_server():
    print("🧪 Testing AI server API...")
    
    # Test server health
    try:
        response = requests.get('http://localhost:5000')
        print("✅ Server responding")
    except:
        print("❌ Server not running - start with: python ai_server.py")
        return False
    
    # Test translation endpoint
    test_image = np.zeros((100, 100, 3), dtype=np.uint8)
    cv2.circle(test_image, (50, 50), 20, (255, 255, 255), -1)
    
    _, buffer = cv2.imencode('.jpg', test_image)
    image_base64 = base64.b64encode(buffer).decode('utf-8')
    
    payload = {
        'image': image_base64,
        'language': 'asl'
    }
    
    response = requests.post('http://localhost:5000/translate', json=payload)
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ API Response: {data}")
        return True
    else:
        print(f"❌ API Error: {response.status_code}")
        return False

if __name__ == "__main__":
    if test_ai_server():
        print("🎉 AI SERVER: PASS")
    else:
        print("❌ AI SERVER: FAIL")
```

---

## 🌐 Part B: Backend Server Testing

### B1: Server Health Test
**File: `test_backend.js`**
```javascript
const axios = require('axios');
const BASE_URL = 'http://localhost:3000';

async function testServerHealth() {
    try {
        const response = await axios.get(BASE_URL);
        console.log('✅ Backend server responding');
        return true;
    } catch (error) {
        console.log('❌ Backend server not responding');
        console.log('💡 Start with: node server.js');
        return false;
    }
}

async function testAuthentication() {
    console.log('🧪 Testing authentication...');
    
    const testUser = {
        email: 'test@example.com',
        password: 'testpass'
    };
    
    try {
        const response = await axios.post(`${BASE_URL}/auth/login`, testUser);
        const data = response.data;
        
        if (data.success && data.user && data.token) {
            console.log('✅ Authentication works');
            console.log(`✅ User: ${data.user.email}`);
            return data.user;
        }
        return false;
    } catch (error) {
        console.log('❌ Authentication failed');
        return false;
    }
}

async function testTranslation(user) {
    console.log('🧪 Testing translation endpoints...');
    
    const sessionData = {
        userId: user.id,
        language: 'asl'
    };
    
    try {
        const response = await axios.post(`${BASE_URL}/translation/start`, sessionData);
        const data = response.data;
        
        if (data.success && data.session) {
            console.log('✅ Translation session created');
            return true;
        }
        return false;
    } catch (error) {
        console.log('❌ Translation endpoint failed');
        return false;
    }
}

async function testVideoRooms(user) {
    console.log('🧪 Testing video rooms...');
    
    try {
        // Create room
        const createResponse = await axios.post(`${BASE_URL}/rooms/create`, {
            userId: user.id
        });
        
        const room = createResponse.data.room;
        console.log(`✅ Room created: ${room.code}`);
        
        // Join room
        const joinResponse = await axios.post(`${BASE_URL}/rooms/join`, {
            roomCode: room.code,
            userId: user.id
        });
        
        console.log('✅ Room joined successfully');
        return true;
    } catch (error) {
        console.log('❌ Video room test failed');
        return false;
    }
}

async function runTests() {
    console.log('🚀 Starting Backend Tests...\n');
    
    if (!await testServerHealth()) return;
    
    const user = await testAuthentication();
    if (!user) return;
    
    await testTranslation(user);
    await testVideoRooms(user);
    
    console.log('\n🎉 ALL BACKEND TESTS COMPLETE!');
}

runTests();
```

### B2: Run Backend Tests
```bash
# Terminal 1: Start backend
node server.js

# Terminal 2: Run tests  
npm install axios
node test_backend.js
```

---

## ✅ Final Testing Checklist

### ML System Tests
- [ ] Python environment setup ✓
- [ ] MediaPipe hand detection ✓  
- [ ] Translation logic ✓
- [ ] AI server API ✓

### Backend Server Tests  
- [ ] Node.js environment ✓
- [ ] Server health ✓
- [ ] Authentication ✓
- [ ] Translation endpoints ✓
- [ ] Video room endpoints ✓

### Integration Ready
- [ ] All ML tests pass ✓
- [ ] All backend tests pass ✓
- [ ] Zero errors in isolation ✓
- [ ] Ready for Flutter connection ✓

---

**Only proceed to integration when ALL tests pass!** 🎯
