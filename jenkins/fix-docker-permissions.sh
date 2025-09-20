#!/bin/bash

# Fix Docker permissions for Jenkins user

echo "🔧 Fixing Docker Permissions for Jenkins"
echo "========================================"

echo "❌ Problem: Jenkins user doesn't have permission to access Docker daemon"
echo "✅ Solution: Add Jenkins user to docker group and restart Jenkins"

echo ""
echo "📋 Manual Steps to Fix:"
echo ""

echo "1. Add Jenkins user to docker group:"
echo "   sudo usermod -aG docker jenkins"

echo ""
echo "2. Restart Jenkins service:"
echo "   sudo systemctl restart jenkins"

echo ""
echo "3. Verify Jenkins is running:"
echo "   sudo systemctl status jenkins"

echo ""
echo "4. Test Docker access (optional):"
echo "   sudo -u jenkins docker version"

echo ""
echo "🎯 Alternative: If the above doesn't work, try:"
echo "   sudo chmod 666 /var/run/docker.sock"
echo "   # Note: This is less secure but will work for testing"

echo ""
echo "After fixing permissions, your Jenkins pipeline should be able to build Docker images! 🚀"
