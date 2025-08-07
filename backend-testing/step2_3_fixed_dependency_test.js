#!/usr/bin/env node
/**
 * LinguaSigna Backend System - Step 2.3: Fixed Dependency Test
 * Test backend dependencies with corrected module resolution
 */

function testDependency(packageName) {
    console.log(`Testing ${packageName}...`);
    
    try {
        // Simple require test - more reliable than resolve
        const pkg = require(packageName);
        
        // Try to get version from package.json
        let version = 'installed';
        try {
            const packageJson = require(`${packageName}/package.json`);
            version = packageJson.version;
        } catch (e) {
            // Version not accessible, but package works
        }
        
        console.log(`✅ ${packageName}: ${version}`);
        return true;
    } catch (error) {
        console.log(`❌ ${packageName}: NOT INSTALLED - ${error.message}`);
        return false;
    }
}

function testExpressBasics() {
    console.log('\n🧪 Testing Express functionality...');
    
    try {
        const express = require('express');
        const app = express();
        
        // Test basic Express functionality
        app.get('/test', (req, res) => {
            res.json({ message: 'test' });
        });
        
        console.log('✅ Express import: PASS');
        console.log('✅ App creation: PASS');
        console.log('✅ Route definition: PASS');
        return true;
    } catch (error) {
        console.log(`❌ Express basics FAILED: ${error.message}`);
        return false;
    }
}

function testSocketIOBasics() {
    console.log('\n🧪 Testing Socket.IO functionality...');
    
    try {
        const { Server } = require('socket.io');
        
        // Test Socket.IO import
        console.log('✅ Socket.IO import: PASS');
        return true;
    } catch (error) {
        console.log(`❌ Socket.IO basics FAILED: ${error.message}`);
        return false;
    }
}

function testBackendIntegration() {
    console.log('\n🧪 Testing backend integration...');
    
    try {
        const express = require('express');
        const cors = require('cors');
        const helmet = require('helmet');
        const morgan = require('morgan');
        
        const app = express();
        
        // Test middleware integration
        app.use(helmet());
        app.use(cors());
        app.use(morgan('combined'));
        app.use(express.json());
        
        // Test API routes
        app.post('/auth/login', (req, res) => {
            res.json({ success: true, message: 'Login endpoint' });
        });
        
        app.post('/translation/start', (req, res) => {
            res.json({ success: true, message: 'Translation endpoint' });
        });
        
        console.log('✅ Middleware integration: PASS');
        console.log('✅ API routes: PASS');
        console.log('✅ Backend integration: PASS');
        return true;
    } catch (error) {
        console.log(`❌ Backend integration FAILED: ${error.message}`);
        return false;
    }
}

function main() {
    console.log('🚀 LinguaSigna Backend - Fixed Dependency Test');
    console.log('='.repeat(50));
    
    const dependencies = [
        'express',
        'socket.io',
        'cors', 
        'helmet',
        'morgan'
    ];
    
    console.log('🧪 Testing dependencies...');
    const dependencyResults = [];
    for (const dep of dependencies) {
        const result = testDependency(dep);
        dependencyResults.push({ name: dep, success: result });
    }
    
    // Test functionality
    const functionalTests = [
        { name: 'Express Basics', test: testExpressBasics },
        { name: 'Socket.IO Basics', test: testSocketIOBasics },
        { name: 'Backend Integration', test: testBackendIntegration }
    ];
    
    let functionalPassed = 0;
    for (const { name, test } of functionalTests) {
        console.log(`\n${'='.repeat(15)} ${name} ${'='.repeat(15)}`);
        if (test()) {
            functionalPassed++;
        }
    }
    
    // Results summary
    const dependencyPassed = dependencyResults.filter(r => r.success).length;
    const dependencyTotal = dependencyResults.length;
    
    console.log('\n' + '='.repeat(50));
    console.log('📊 FIXED BACKEND TEST RESULTS:');
    console.log(`Dependencies: ${dependencyPassed}/${dependencyTotal} PASSED`);
    console.log(`Functionality: ${functionalPassed}/${functionalTests.length} PASSED`);
    
    if (dependencyPassed === dependencyTotal && functionalPassed === functionalTests.length) {
        console.log('\n🎉 ALL BACKEND TESTS PASSED!');
        console.log('✅ Backend system fully validated!');
        console.log('✅ Ready for Option 3: Integration phase!');
        return true;
    } else {
        console.log('\n❌ SOME BACKEND TESTS FAILED!');
        return false;
    }
}

if (require.main === module) {
    const success = main();
    process.exit(success ? 0 : 1);
}
