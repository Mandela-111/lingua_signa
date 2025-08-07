#!/usr/bin/env python3
"""
LinguaSigna ML Server - Simple Implementation for Integration Testing
Based on our simplified guide
"""

from flask import Flask, request, jsonify
import base64
import json
import random
import time
from datetime import datetime

app = Flask(__name__)

class SimpleSignTranslator:
    def __init__(self):
        self.asl_words = [
            "Hello", "Thank you", "Please", "Sorry", "Yes", "No",
            "Good morning", "How are you?", "Nice to meet you"
        ]
        self.gsl_words = [
            "Akwaaba", "Medaase", "Mepa wo kyɛw", "Kafra", "Aane", "Daabi",
            "Mema wo akye", "Wo ho te sɛn?", "Me ani agye"
        ]
    
    def translate(self, image_data, language="asl"):
        """Mock translation - returns random sign language word"""
        # Simulate processing time
        time.sleep(0.1)
        
        # Simple logic: if image_data exists, return translation
        if image_data and len(image_data) > 10:  # Basic validation
            words = self.asl_words if language == "asl" else self.gsl_words
            translation = random.choice(words)
            confidence = random.uniform(0.80, 0.95)
            
            return {
                "text": translation,
                "confidence": confidence,
                "language": language,
                "timestamp": datetime.now().isoformat()
            }
        else:
            return None

# Initialize translator
translator = SimpleSignTranslator()

@app.route('/', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": "LinguaSigna ML Server",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0"
    })

@app.route('/health', methods=['GET'])
def health_check():
    """Alternative health check endpoint"""
    return health()

@app.route('/translate', methods=['POST'])
def translate_frame():
    """Main translation endpoint"""
    try:
        # Get request data
        data = request.json
        
        if not data:
            return jsonify({
                "success": False,
                "error": "No JSON data provided"
            }), 400
        
        # Extract image and language
        image_data = data.get('image', '')
        language = data.get('language', 'asl').lower()
        
        # Validate language
        if language not in ['asl', 'gsl']:
            return jsonify({
                "success": False,
                "error": f"Unsupported language: {language}"
            }), 400
        
        # Try to decode base64 image (basic validation)
        try:
            if image_data:
                decoded_data = base64.b64decode(image_data)
            else:
                decoded_data = None
        except Exception:
            return jsonify({
                "success": False,
                "error": "Invalid base64 image data"
            }), 400
        
        # Perform translation
        result = translator.translate(decoded_data, language)
        
        if result:
            return jsonify({
                "success": True,
                "translation": result["text"],
                "confidence": result["confidence"],
                "language": result["language"],
                "timestamp": result["timestamp"],
                "processing_time_ms": 100
            })
        else:
            return jsonify({
                "success": False,
                "message": "No hands detected or invalid image",
                "language": language,
                "timestamp": datetime.now().isoformat()
            })
            
    except Exception as e:
        print(f"Translation error: {e}")
        return jsonify({
            "success": False,
            "error": f"Internal server error: {str(e)}"
        }), 500

@app.route('/status', methods=['GET'])
def status():
    """Server status endpoint"""
    return jsonify({
        "server": "ML Translation Server",
        "status": "running",
        "endpoints": [
            "/health - Health check",
            "/translate - POST translation endpoint",
            "/status - This status endpoint"
        ],
        "languages_supported": ["asl", "gsl"],
        "timestamp": datetime.now().isoformat()
    })

if __name__ == '__main__':
    print("🚀 Starting LinguaSigna ML Server...")
    print("📡 Server will be available at http://localhost:5000")
    print("🔗 Endpoints:")
    print("   GET  /health - Health check")
    print("   POST /translate - Translation API")
    print("   GET  /status - Server status")
    print("✅ ML Server ready for integration testing!")
    
    app.run(host='0.0.0.0', port=5000, debug=False)
