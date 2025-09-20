#!/bin/bash

# Fix Jenkins Java version issue
# Jenkins requires Java 17 or higher, but we have Java 11

echo "🔧 Fixing Jenkins Java Version Issue"
echo "===================================="

echo "❌ Problem: Jenkins requires Java 17+, but we have Java 11"
echo "✅ Solution: Install Java 17 and configure Jenkins to use it"

echo ""
echo "📋 Manual Steps to Fix:"
echo ""

echo "1. Install Java 17:"
echo "   sudo apt update"
echo "   sudo apt install -y openjdk-17-jdk"

echo ""
echo "2. Set Java 17 as default:"
echo "   sudo update-alternatives --config java"
echo "   # Select Java 17 from the list"

echo ""
echo "3. Verify Java version:"
echo "   java -version"
echo "   # Should show: openjdk version \"17.x.x\""

echo ""
echo "4. Start Jenkins:"
echo "   sudo systemctl start jenkins"
echo "   sudo systemctl status jenkins"

echo ""
echo "5. Get initial admin password:"
echo "   sudo cat /var/lib/jenkins/secrets/initialAdminPassword"

echo ""
echo "6. Access Jenkins:"
echo "   http://$(hostname -I | awk '{print $1}'):8080"

echo ""
echo "🎯 Alternative: If you prefer Java 21 (latest LTS):"
echo "   sudo apt install -y openjdk-21-jdk"
echo "   sudo update-alternatives --config java"

echo ""
echo "After fixing Java, Jenkins should start successfully! 🚀"
