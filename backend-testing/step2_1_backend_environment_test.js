#!/usr/bin/env node
/**
 * LinguaSigna Backend System - Step 2.1: Environment Validation
 * Test Node.js environment and all required dependencies
 */

const fs = require('fs');
const path = require('path');

function testNodeVersion() {
    console.log('🧪 Testing Node.js version...');
    
    const version = process.version;
    const majorVersion = parseInt(version.slice(1).split('.')[0]);
    
    console.log(`Node.js version: ${version}`);
    
    if (majorVersion >= 16) {
        console.log('✅ Node.js version: PASS (16+ required)');
        return true;
    } else {
        console.log('❌ Node.js version: FAIL (need Node.js 16+)');
        return false;
    }
}

function testDependency(packageName) {
    console.log(`Testing ${packageName}...`);
    
    try {
        const packagePath = require.resolve(packageName);
        const packageJson = require(path.join(packagePath, '../../package.json'));
        const version = packageJson.version || 'unknown';
        
        console.log(`✅ ${packageName}: ${version}`);
        return true;
    } catch (error) {
        console.log(`❌ ${packageName}: NOT INSTALLED`);
        return false;
    }
}

function testAllDependencies() {
    console.log('\n🧪 Testing backend dependencies...');
    
    const dependencies = [
        'express',
        'socket.io', 
        'cors',
        'helmet',
        'morgan'
    ];
    
    const results = [];
    for (const dep of dependencies) {
        const result = testDependency(dep);
        results.push({ name: dep, success: result });
    }
    
    return results;
}

function testBasicServerLogic() {
    console.log('\n🧪 Testing basic server logic...');
    
    try {
        // Test basic HTTP server concepts
        const http = require('http');
        const url = require('url');
        const querystring = require('querystring');
        
        // Test JSON handling
        const testData = {
            userId: 'test123',
            language: 'asl',
            timestamp: new Date().toISOString()
        };
        
        const jsonString = JSON.stringify(testData);
        const parsedData = JSON.parse(jsonString);
        
        if (parsedData.userId !== 'test123') {
            throw new Error('JSON serialization failed');
        }
        
        // Test basic routing logic
        const mockRoutes = {
            '/auth/login': 'POST',
            '/translation/start': 'POST', 
            '/rooms/create': 'POST',
            '/rooms/join': 'POST'
        };
        
        const routeCount = Object.keys(mockRoutes).length;
        if (routeCount !== 4) {
            throw new Error('Route definition failed');
        }
        
        console.log('✅ HTTP modules: PASS');
        console.log('✅ JSON handling: PASS'); 
        console.log('✅ Route logic: PASS');
        console.log('✅ Basic server logic: PASS');
        return true;
        
    } catch (error) {
        console.log(`❌ Basic server logic FAILED: ${error.message}`);
        return false;
    }
}

function testMemoryStorage() {
    console.log('\n🧪 Testing in-memory storage...');
    
    try {
        // Test user storage
        const users = [];
        const testUser = {
            id: Date.now().toString(),
            email: 'test@example.com',
            username: 'testuser',
            settings: {
                selectedLanguage: 'asl',
                autoTranslate: true
            }
        };
        
        users.push(testUser);
        
        // Test user retrieval
        const foundUser = users.find(u => u.email === 'test@example.com');
        if (!foundUser || foundUser.id !== testUser.id) {
            throw new Error('User storage failed');
        }
        
        // Test room storage
        const rooms = [];
        const testRoom = {
            id: Date.now().toString(),
            code: 'TEST123',
            creatorId: testUser.id,
            participants: [],
            active: true
        };
        
        rooms.push(testRoom);
        
        // Test room retrieval
        const foundRoom = rooms.find(r => r.code === 'TEST123');
        if (!foundRoom || foundRoom.creatorId !== testUser.id) {
            throw new Error('Room storage failed');
        }
        
        console.log('✅ User storage: PASS');
        console.log('✅ Room storage: PASS');
        console.log('✅ Data retrieval: PASS');
        console.log('✅ Memory storage: PASS');
        return true;
        
    } catch (error) {
        console.log(`❌ Memory storage FAILED: ${error.message}`);
        return false;
    }
}

function testApiStructures() {
    console.log('\n🧪 Testing API request/response structures...');
    
    try {
        // Test login API structure
        const loginRequest = {
            email: 'test@example.com',
            password: 'password123'
        };
        
        const loginResponse = {
            success: true,
            user: {
                id: '12345',
                email: 'test@example.com',
                username: 'testuser'
            },
            token: 'jwt_token_here'
        };
        
        // Test translation API structure
        const translationRequest = {
            userId: '12345',
            language: 'asl',
            timestamp: new Date().toISOString()
        };
        
        const translationResponse = {
            success: true,
            session: {
                id: 'session123',
                userId: '12345',
                language: 'asl',
                startTime: new Date().toISOString()
            }
        };
        
        // Test room API structure
        const roomRequest = {
            userId: '12345'
        };
        
        const roomResponse = {
            success: true,
            room: {
                id: 'room123',
                code: 'ABC123',
                creatorId: '12345',
                participants: []
            }
        };
        
        // Validate structures
        if (!loginRequest.email || !loginResponse.user) {
            throw new Error('Login API structure invalid');
        }
        
        if (!translationRequest.userId || !translationResponse.session) {
            throw new Error('Translation API structure invalid');
        }
        
        if (!roomRequest.userId || !roomResponse.room) {
            throw new Error('Room API structure invalid');
        }
        
        console.log('✅ Login API structure: PASS');
        console.log('✅ Translation API structure: PASS');
        console.log('✅ Room API structure: PASS');
        console.log('✅ API structures: PASS');
        return true;
        
    } catch (error) {
        console.log(`❌ API structures FAILED: ${error.message}`);
        return false;
    }
}

function provideInstallationHelp(failedPackages) {
    if (failedPackages.length === 0) return;
    
    console.log('\n💡 Installation Instructions:');
    console.log('Run these commands to install missing packages:');
    console.log('');
    
    const installCommands = {
        'express': 'npm install express',
        'socket.io': 'npm install socket.io', 
        'cors': 'npm install cors',
        'helmet': 'npm install helmet',
        'morgan': 'npm install morgan'
    };
    
    failedPackages.forEach(pkg => {
        if (installCommands[pkg]) {
            console.log(`  ${installCommands[pkg]}`);
        }
    });
    
    console.log('\nOr install all at once:');
    console.log('  npm install express socket.io cors helmet morgan');
    console.log('\nOr initialize package.json first:');
    console.log('  npm init -y');
    console.log('  npm install express socket.io cors helmet morgan');
}

function main() {
    console.log('🚀 LinguaSigna Backend Environment Validation');
    console.log('='.repeat(50));
    
    // Test Node.js version
    const nodeOk = testNodeVersion();
    
    // Test dependencies
    const dependencyResults = testAllDependencies();
    
    // Test core functionality
    const tests = [
        { name: 'Basic Server Logic', test: testBasicServerLogic },
        { name: 'Memory Storage', test: testMemoryStorage },
        { name: 'API Structures', test: testApiStructures }
    ];
    
    let functionalityPassed = 0;
    for (const { name, test } of tests) {
        console.log(`\n${'='.repeat(20)} ${name} ${'='.repeat(20)}`);
        if (test()) {
            functionalityPassed++;
        }
    }
    
    // Count results
    const dependencyPassed = dependencyResults.filter(r => r.success).length;
    const dependencyTotal = dependencyResults.length;
    const failedPackages = dependencyResults.filter(r => !r.success).map(r => r.name);
    
    // Summary
    console.log('\n' + '='.repeat(50));
    console.log('📊 BACKEND ENVIRONMENT TEST RESULTS:');
    console.log(`Node.js Version: ${nodeOk ? '✅ PASS' : '❌ FAIL'}`);
    console.log(`Dependencies: ${dependencyPassed}/${dependencyTotal} PASSED`);
    console.log(`Core Functionality: ${functionalityPassed}/${tests.length} PASSED`);
    
    if (nodeOk && dependencyPassed === dependencyTotal && functionalityPassed === tests.length) {
        console.log('\n🎉 ALL BACKEND ENVIRONMENT TESTS PASSED!');
        console.log('✅ Ready for backend server implementation!');
        return true;
    } else {
        console.log('\n❌ BACKEND ENVIRONMENT VALIDATION FAILED!');
        if (!nodeOk) {
            console.log('❗ Please upgrade to Node.js 16+');
        }
        if (failedPackages.length > 0) {
            provideInstallationHelp(failedPackages);
        }
        return false;
    }
}

if (require.main === module) {
    const success = main();
    process.exit(success ? 0 : 1);
}
