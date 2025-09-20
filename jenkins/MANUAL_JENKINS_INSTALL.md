# Manual Jenkins Installation on workernode2

## Current Status
- ✅ Java 11 is installed
- ✅ Docker is available
- ✅ kubectl is available
- ❌ Jenkins is not installed

## Manual Installation Steps

### Step 1: Update System
```bash
sudo apt update
```

### Step 2: Install Required Packages
```bash
sudo apt install -y wget curl gnupg2 software-properties-common apt-transport-https ca-certificates
```

### Step 3: Add Jenkins Repository Key
```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
```

### Step 4: Add Jenkins Repository
```bash
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
```

### Step 5: Update Package List
```bash
sudo apt update
```

### Step 6: Install Jenkins
```bash
sudo apt install -y jenkins
```

### Step 7: Start and Enable Jenkins
```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

### Step 8: Check Jenkins Status
```bash
sudo systemctl status jenkins
```

### Step 9: Get Initial Admin Password
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Step 10: Add Jenkins User to Docker Group
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

## Access Jenkins

### Get Machine IP
```bash
hostname -I | awk '{print $1}'
```

### Access URL
```
http://YOUR_MACHINE_IP:8080
```

## Initial Setup

1. **Open browser** and go to `http://YOUR_MACHINE_IP:8080`
2. **Enter initial admin password** (from step 9)
3. **Install suggested plugins**
4. **Create admin user**
5. **Configure Jenkins**

## After Installation

### Create a Simple Pipeline Job
1. Go to Jenkins → New Item
2. Enter name: `end-to-end-project`
3. Select: `Pipeline`
4. Click OK
5. In Pipeline section:
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/omarzaki222/EndtoEnd-Project.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile-agent`

### Configure Credentials
1. Go to Jenkins → Manage Jenkins → Manage Credentials
2. Add credentials for:
   - Docker Hub: `docker-hub-credentials`
   - GitHub: `github-token`

## Benefits of This Setup

- ✅ **Direct Docker access** - No container limitations
- ✅ **Direct kubectl access** - No workarounds needed
- ✅ **Simple pipeline** - Standard Jenkins practices
- ✅ **Easy debugging** - Can SSH into the machine
- ✅ **Better performance** - Dedicated resources

## Next Steps After Installation

1. **Install Jenkins** using the steps above
2. **Access Jenkins web UI** and complete setup
3. **Create pipeline job** with the GitHub repository
4. **Configure credentials** for Docker Hub and GitHub
5. **Test the pipeline** with a build

This setup will give you a clean, reliable CI/CD pipeline! 🚀
