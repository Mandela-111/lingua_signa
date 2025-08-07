#!/usr/bin/env python3
"""
LinguaSigna Integration Test Runner
Runs both servers and executes comprehensive integration tests
"""

import subprocess
import time
import sys
import signal
import os
import threading
from step3_1_integration_test import IntegrationTester

class TestRunner:
    def __init__(self):
        self.ml_process = None
        self.backend_process = None
        self.processes = []
    
    def start_ml_server(self):
        """Start the ML server"""
        print("🚀 Starting ML Server...")
        try:
            self.ml_process = subprocess.Popen([
                sys.executable, 'ml_server.py'
            ], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            self.processes.append(self.ml_process)
            print("✅ ML Server process started")
            return True
        except Exception as e:
            print(f"❌ Failed to start ML Server: {e}")
            return False
    
    def start_backend_server(self):
        """Start the Backend server"""
        print("🚀 Starting Backend Server...")
        try:
            self.backend_process = subprocess.Popen([
                'node', 'backend_server.js'
            ], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            self.processes.append(self.backend_process)
            print("✅ Backend Server process started")
            return True
        except Exception as e:
            print(f"❌ Failed to start Backend Server: {e}")
            return False
    
    def wait_for_servers(self, timeout=15):
        """Wait for both servers to be ready"""
        print("⏳ Waiting for servers to be ready...")
        
        import requests
        ml_ready = False
        backend_ready = False
        
        start_time = time.time()
        while time.time() - start_time < timeout:
            # Check ML server
            if not ml_ready:
                try:
                    response = requests.get('http://localhost:5000/health', timeout=2)
                    if response.status_code == 200:
                        ml_ready = True
                        print("✅ ML Server is ready!")
                except:
                    pass
            
            # Check Backend server
            if not backend_ready:
                try:
                    response = requests.get('http://localhost:3000/health', timeout=2)
                    if response.status_code == 200:
                        backend_ready = True
                        print("✅ Backend Server is ready!")
                except:
                    pass
            
            if ml_ready and backend_ready:
                print("🎉 Both servers are ready!")
                return True
            
            time.sleep(1)
        
        print(f"❌ Servers not ready after {timeout}s")
        print(f"   ML Server ready: {ml_ready}")
        print(f"   Backend Server ready: {backend_ready}")
        return False
    
    def stop_servers(self):
        """Stop all server processes"""
        print("🛑 Stopping servers...")
        
        for process in self.processes:
            if process and process.poll() is None:
                try:
                    process.terminate()
                    process.wait(timeout=5)
                    print("✅ Server stopped gracefully")
                except subprocess.TimeoutExpired:
                    process.kill()
                    print("⚠️  Server force killed")
                except Exception as e:
                    print(f"⚠️  Error stopping server: {e}")
        
        self.processes = []
        print("✅ All servers stopped")
    
    def run_integration_tests(self):
        """Run the complete integration test suite"""
        print("🧪 Starting Integration Test Suite...")
        print("=" * 60)
        
        # Start servers
        ml_started = self.start_ml_server()
        backend_started = self.start_backend_server()
        
        if not (ml_started and backend_started):
            print("❌ Failed to start servers - aborting tests")
            self.stop_servers()
            return False
        
        # Wait for servers to be ready
        if not self.wait_for_servers():
            print("❌ Servers not ready - aborting tests")
            self.stop_servers()
            return False
        
        # Run integration tests
        print("\n🧪 Running Integration Tests...")
        print("=" * 60)
        
        try:
            tester = IntegrationTester()
            test_success = tester.run_integration_tests()
            
            print("\n" + "=" * 60)
            if test_success:
                print("🎉 INTEGRATION TESTS COMPLETED SUCCESSFULLY!")
                print("✅ ML + Backend systems working perfectly together!")
                print("✅ Ready for Flutter frontend integration!")
            else:
                print("❌ INTEGRATION TESTS FAILED!")
                print("🔧 Review the errors above and fix before proceeding")
            
            return test_success
        
        except Exception as e:
            print(f"💥 Integration test error: {e}")
            return False
        
        finally:
            self.stop_servers()

def signal_handler(signum, frame):
    """Handle Ctrl+C gracefully"""
    print("\n🛑 Interrupted by user - cleaning up...")
    sys.exit(0)

def main():
    """Main test runner"""
    signal.signal(signal.SIGINT, signal_handler)
    
    print("🚀 LinguaSigna ML + Backend Integration Test Runner")
    print("=" * 60)
    print("This will:")
    print("  1. Start ML Server (Python Flask)")
    print("  2. Start Backend Server (Node.js Express)")
    print("  3. Wait for both servers to be ready")
    print("  4. Run comprehensive integration tests")
    print("  5. Stop servers and report results")
    print("=" * 60)
    
    runner = TestRunner()
    
    try:
        success = runner.run_integration_tests()
        
        if success:
            print("\n🎯 NEXT STEPS:")
            print("   ✅ Both systems validated and working together")
            print("   ✅ Ready to integrate with Flutter frontend")
            print("   🚀 You can now connect your optimized Flutter app!")
        else:
            print("\n🔧 REQUIRED FIXES:")
            print("   ❌ Review integration test failures above")
            print("   🔍 Fix any issues before Flutter integration")
        
        sys.exit(0 if success else 1)
    
    except Exception as e:
        print(f"\n💥 Test runner error: {e}")
        runner.stop_servers()
        sys.exit(1)

if __name__ == "__main__":
    main()
