#!/usr/bin/env python3
"""
LinguaSigna ML System - Step 1: Environment Validation
Test Python environment and all required dependencies
"""

import sys
import importlib.util

def test_python_version():
    """Test 1: Verify Python version compatibility"""
    print("🧪 Testing Python version...")
    
    version = sys.version_info
    print(f"Python version: {version.major}.{version.minor}.{version.micro}")
    
    if version.major >= 3 and version.minor >= 8:
        print("✅ Python version: PASS (3.8+ required)")
        return True
    else:
        print("❌ Python version: FAIL (need Python 3.8+)")
        return False

def test_dependency(package_name, import_name=None):
    """Test if a package is installed and can be imported"""
    if import_name is None:
        import_name = package_name
    
    try:
        spec = importlib.util.find_spec(import_name)
        if spec is None:
            print(f"❌ {package_name}: NOT INSTALLED")
            return False
        
        # Try to import the module
        module = importlib.import_module(import_name)
        
        # Get version if available
        version = "unknown"
        if hasattr(module, '__version__'):
            version = module.__version__
        elif hasattr(module, 'version'):
            version = module.version
        
        print(f"✅ {package_name}: {version}")
        return True
        
    except ImportError as e:
        print(f"❌ {package_name}: IMPORT ERROR - {e}")
        return False
    except Exception as e:
        print(f"❌ {package_name}: ERROR - {e}")
        return False

def test_all_dependencies():
    """Test all required ML dependencies"""
    print("\n🧪 Testing ML dependencies...")
    
    dependencies = [
        ("TensorFlow", "tensorflow"),
        ("MediaPipe", "mediapipe"), 
        ("OpenCV", "cv2"),
        ("Flask", "flask"),
        ("NumPy", "numpy"),
        ("Pillow", "PIL")
    ]
    
    results = []
    for package_name, import_name in dependencies:
        result = test_dependency(package_name, import_name)
        results.append((package_name, result))
    
    return results

def provide_installation_help(failed_packages):
    """Provide installation instructions for failed packages"""
    if not failed_packages:
        return
    
    print("\n💡 Installation Instructions:")
    print("Run these commands to install missing packages:")
    print()
    
    install_commands = {
        "TensorFlow": "pip install tensorflow",
        "MediaPipe": "pip install mediapipe",
        "OpenCV": "pip install opencv-python",
        "Flask": "pip install flask", 
        "NumPy": "pip install numpy",
        "Pillow": "pip install Pillow"
    }
    
    for package in failed_packages:
        if package in install_commands:
            print(f"  {install_commands[package]}")
    
    print("\nOr install all at once:")
    print("  pip install tensorflow mediapipe opencv-python flask numpy Pillow")

def main():
    """Run complete environment validation"""
    print("🚀 LinguaSigna ML Environment Validation")
    print("=" * 50)
    
    # Test Python version
    python_ok = test_python_version()
    
    # Test dependencies
    dependency_results = test_all_dependencies()
    
    # Count results
    passed = sum(1 for _, result in dependency_results if result)
    total = len(dependency_results)
    failed_packages = [name for name, result in dependency_results if not result]
    
    # Summary
    print("\n" + "=" * 50)
    print("📊 ENVIRONMENT TEST RESULTS:")
    print(f"Python Version: {'✅ PASS' if python_ok else '❌ FAIL'}")
    print(f"Dependencies: {passed}/{total} PASSED")
    
    if python_ok and passed == total:
        print("\n🎉 ALL ENVIRONMENT TESTS PASSED!")
        print("✅ Ready for ML system implementation!")
        return True
    else:
        print("\n❌ ENVIRONMENT VALIDATION FAILED!")
        if not python_ok:
            print("❗ Please upgrade to Python 3.8+")
        if failed_packages:
            provide_installation_help(failed_packages)
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
