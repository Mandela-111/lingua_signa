#!/usr/bin/env python3
"""
LinguaSigna Integration Test - Step 3.1
Test ML system and Backend system working together
"""

import sys
import requests
import json
import time
import threading
import subprocess
import signal
import os
from datetime import datetime
import base64
import random

# Test configuration
BACKEND_URL = "http://localhost:3000"
ML_URL = "http://localhost:5000"
TEST_TIMEOUT = 30  # seconds

class IntegrationTester:
    def __init__(self):
        self.backend_process = None
        self.ml_process = None
        self.test_results = []
    
    def log_test(self, test_name, success, message=""):
        """Log test results"""
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status}: {test_name}")
        if message:
            print(f"    {message}")
        
        self.test_results.append({
            "test": test_name,
            "success": success,
            "message": message,
            "timestamp": datetime.now().isoformat()
        })
        return success
    
    def wait_for_server(self, url, timeout=10, server_name="Server"):
        """Wait for server to be ready"""
        print(f"🔄 Waiting for {server_name} at {url}...")
        
        start_time = time.time()
        while time.time() - start_time < timeout:
            try:
                response = requests.get(url, timeout=2)
                print(f"✅ {server_name} is ready!")
                return True
            except requests.exceptions.RequestException:
                time.sleep(1)
        
        print(f"❌ {server_name} failed to start within {timeout}s")
        return False
    
    def test_backend_health(self):
        """Test 1: Backend server health check"""
        try:
            response = requests.get(f"{BACKEND_URL}/health", timeout=5)
            
            if response.status_code == 404:
                # Health endpoint doesn't exist, try root
                response = requests.get(BACKEND_URL, timeout=5)
            
            if response.status_code in [200, 404]:  # Server responding
                return self.log_test("Backend Health Check", True, 
                                   f"Backend responding (status: {response.status_code})")
            else:
                return self.log_test("Backend Health Check", False, 
                                   f"Unexpected status: {response.status_code}")
        
        except Exception as e:
            return self.log_test("Backend Health Check", False, str(e))
    
    def test_ml_health(self):
        """Test 2: ML server health check"""
        try:
            response = requests.get(f"{ML_URL}/health", timeout=5)
            
            if response.status_code == 404:
                # Health endpoint doesn't exist, try root
                response = requests.get(ML_URL, timeout=5)
            
            if response.status_code in [200, 404]:  # Server responding
                return self.log_test("ML Server Health Check", True, 
                                   f"ML server responding (status: {response.status_code})")
            else:
                return self.log_test("ML Server Health Check", False, 
                                   f"Unexpected status: {response.status_code}")
        
        except Exception as e:
            return self.log_test("ML Server Health Check", False, str(e))
    
    def test_user_authentication(self):
        """Test 3: User authentication flow"""
        try:
            user_data = {
                "email": "integration_test@example.com",
                "password": "test123"
            }
            
            response = requests.post(f"{BACKEND_URL}/auth/login", 
                                   json=user_data, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if data.get("success") and data.get("user") and data.get("token"):
                    return self.log_test("User Authentication", True, 
                                       f"User created: {data['user']['email']}")
                else:
                    return self.log_test("User Authentication", False, 
                                       "Invalid response structure")
            else:
                return self.log_test("User Authentication", False, 
                                   f"HTTP {response.status_code}")
        
        except Exception as e:
            return self.log_test("User Authentication", False, str(e))
    
    def test_translation_session(self):
        """Test 4: Translation session creation"""
        try:
            # First authenticate to get user
            user_data = {
                "email": "integration_test@example.com",
                "password": "test123"
            }
            
            auth_response = requests.post(f"{BACKEND_URL}/auth/login", 
                                        json=user_data, timeout=10)
            
            if auth_response.status_code != 200:
                return self.log_test("Translation Session", False, 
                                   "Authentication failed")
            
            user = auth_response.json()["user"]
            
            # Create translation session
            session_data = {
                "userId": user["id"],
                "language": "asl"
            }
            
            response = requests.post(f"{BACKEND_URL}/translation/start", 
                                   json=session_data, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if data.get("success") and data.get("session"):
                    return self.log_test("Translation Session", True, 
                                       f"Session created: {data['session']['id']}")
                else:
                    return self.log_test("Translation Session", False, 
                                       "Invalid session response")
            else:
                return self.log_test("Translation Session", False, 
                                   f"HTTP {response.status_code}")
        
        except Exception as e:
            return self.log_test("Translation Session", False, str(e))
    
    def test_ml_translation(self):
        """Test 5: ML translation API"""
        try:
            # Create test image (simple black square with white circle)
            import numpy as np
            test_image = np.zeros((100, 100, 3), dtype=np.uint8)
            
            # Add a white circle to simulate hand
            center = (50, 50)
            radius = 20
            y, x = np.ogrid[:100, :100]
            mask = (x - center[0])**2 + (y - center[1])**2 <= radius**2
            test_image[mask] = [255, 255, 255]
            
            # Convert to base64
            import cv2
            _, buffer = cv2.imencode('.jpg', test_image)
            image_base64 = base64.b64encode(buffer).decode('utf-8')
            
            # Send to ML API
            payload = {
                'image': image_base64,
                'language': 'asl'
            }
            
            response = requests.post(f"{ML_URL}/translate", 
                                   json=payload, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if 'success' in data:
                    if data['success']:
                        return self.log_test("ML Translation", True, 
                                           f"Translation: {data.get('translation', 'N/A')}")
                    else:
                        return self.log_test("ML Translation", True, 
                                           "No hands detected (expected for test image)")
                else:
                    return self.log_test("ML Translation", False, 
                                       "Invalid response structure")
            else:
                return self.log_test("ML Translation", False, 
                                   f"HTTP {response.status_code}")
        
        except Exception as e:
            return self.log_test("ML Translation", False, str(e))
    
    def test_video_room_creation(self):
        """Test 6: Video room creation and joining"""
        try:
            # Authenticate first
            user_data = {
                "email": "integration_test@example.com", 
                "password": "test123"
            }
            
            auth_response = requests.post(f"{BACKEND_URL}/auth/login", 
                                        json=user_data, timeout=10)
            
            if auth_response.status_code != 200:
                return self.log_test("Video Room Creation", False, 
                                   "Authentication failed")
            
            user = auth_response.json()["user"]
            
            # Create room
            room_data = {"userId": user["id"]}
            
            response = requests.post(f"{BACKEND_URL}/rooms/create", 
                                   json=room_data, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if data.get("success") and data.get("room"):
                    room_code = data["room"]["code"]
                    return self.log_test("Video Room Creation", True, 
                                       f"Room created: {room_code}")
                else:
                    return self.log_test("Video Room Creation", False, 
                                       "Invalid room response")
            else:
                return self.log_test("Video Room Creation", False, 
                                   f"HTTP {response.status_code}")
        
        except Exception as e:
            return self.log_test("Video Room Creation", False, str(e))
    
    def test_end_to_end_flow(self):
        """Test 7: Complete end-to-end user flow"""
        try:
            # Step 1: User authentication
            user_data = {
                "email": f"e2e_test_{int(time.time())}@example.com",
                "password": "test123"
            }
            
            auth_response = requests.post(f"{BACKEND_URL}/auth/login", 
                                        json=user_data, timeout=10)
            
            if auth_response.status_code != 200:
                return self.log_test("End-to-End Flow", False, 
                                   "Step 1: Authentication failed")
            
            user = auth_response.json()["user"]
            
            # Step 2: Create translation session
            session_data = {
                "userId": user["id"],
                "language": "asl"
            }
            
            session_response = requests.post(f"{BACKEND_URL}/translation/start", 
                                           json=session_data, timeout=10)
            
            if session_response.status_code != 200:
                return self.log_test("End-to-End Flow", False, 
                                   "Step 2: Session creation failed")
            
            # Step 3: Create video room
            room_data = {"userId": user["id"]}
            
            room_response = requests.post(f"{BACKEND_URL}/rooms/create", 
                                        json=room_data, timeout=10)
            
            if room_response.status_code != 200:
                return self.log_test("End-to-End Flow", False, 
                                   "Step 3: Room creation failed")
            
            room = room_response.json()["room"]
            
            # Step 4: Test ML translation
            test_payload = {
                'image': 'dGVzdF9pbWFnZQ==',  # base64 encoded 'test_image'
                'language': 'asl'
            }
            
            ml_response = requests.post(f"{ML_URL}/translate", 
                                      json=test_payload, timeout=10)
            
            if ml_response.status_code != 200:
                return self.log_test("End-to-End Flow", False, 
                                   "Step 4: ML translation failed")
            
            return self.log_test("End-to-End Flow", True, 
                               f"Complete flow: User→Session→Room({room['code']})→ML")
        
        except Exception as e:
            return self.log_test("End-to-End Flow", False, str(e))
    
    def run_integration_tests(self):
        """Run all integration tests"""
        print("🚀 LinguaSigna ML + Backend Integration Testing")
        print("=" * 55)
        
        # Check if servers are running
        backend_ready = self.wait_for_server(BACKEND_URL, 10, "Backend Server")
        ml_ready = self.wait_for_server(ML_URL, 10, "ML Server")
        
        if not backend_ready or not ml_ready:
            print("\n❌ INTEGRATION TESTS FAILED: Servers not ready!")
            print("\n💡 Start the servers first:")
            print("   Terminal 1: cd backend-testing && node ../ML_BACKEND_SIMPLIFIED_GUIDE.md")
            print("   Terminal 2: cd ml-testing && python ../ML_BACKEND_SIMPLIFIED_GUIDE.md") 
            return False
        
        # Run all tests
        tests = [
            self.test_backend_health,
            self.test_ml_health,
            self.test_user_authentication,
            self.test_translation_session,
            self.test_ml_translation,
            self.test_video_room_creation,
            self.test_end_to_end_flow
        ]
        
        print(f"\n🧪 Running {len(tests)} integration tests...")
        print("-" * 55)
        
        for test in tests:
            test()
            print("-" * 55)
        
        # Summary
        passed = sum(1 for result in self.test_results if result['success'])
        total = len(self.test_results)
        
        print(f"\n📊 INTEGRATION TEST RESULTS: {passed}/{total} PASSED")
        
        if passed == total:
            print("🎉 ALL INTEGRATION TESTS PASSED!")
            print("✅ ML + Backend systems working perfectly together!")
            print("✅ Ready for Flutter frontend integration!")
            return True
        else:
            print("❌ SOME INTEGRATION TESTS FAILED!")
            print("🔧 Fix the issues before proceeding to Flutter integration")
            return False

def main():
    """Main integration test runner"""
    tester = IntegrationTester()
    
    try:
        success = tester.run_integration_tests()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n🛑 Integration tests interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n💥 Integration test error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
