---

# 🎯 Resume Hub  

Resume Hub is an AI-powered resume analysis and job recommendation platform built using **Flutter (frontend)** and **Flask (backend)**. It helps users optimize their resumes for **Applicant Tracking Systems (ATS)** and find the best job matches based on their skills and experience.  

---

## 🎥 Demo Video  
Check out the working video of the application:  
🔗 [Resume Hub - Demo](https://drive.google.com/file/d/1OJ21uz_u8CI801KiUuj4sPBVLBkNm43V/view?usp=sharing)  

---
## 🚀 Features  

✅ **Resume Analysis** – Extracts skills, experience, and education from resumes  
✅ **ATS Optimization** – Checks how well resumes perform in **Applicant Tracking Systems**  
✅ **Job Recommendations** – Uses **AI & NLP** to suggest the best job matches  
✅ **PDF Resume Support** – Upload and analyze **PDF resumes**  
✅ **Flutter UI** – Interactive, modern, and user-friendly mobile app  
✅ **Flask Backend** – API-driven **resume parsing** and **job matching**  

---

## 🏗 Tech Stack  

### 🎨 Frontend (Flutter)  
- **Framework:** Flutter  
- **Language:** Dart  
- **UI Components:** Material Design, Firebase Integration  

### 🔥 Backend (Python + Flask)  
- **Framework:** Flask  
- **NLP & ML:** NLTK, scikit-learn, TF-IDF, Cosine Similarity  
- **Data Processing:** pandas, NumPy  
- **PDF Handling:** PyPDF2  
- **CORS Handling:** Flask-CORS  

---

## 📂 Folder Structure  

```
ResumeHub/  
│── android/               # Flutter Android files  
│── ios/                   # Flutter iOS files  
│── lib/                   # Main Flutter app (Dart code)  
│── assets/                # Images, fonts, etc.  
│── backend/               # Flask API (your Python backend)  
│   ├── app.py             # Flask app entry point  
│   ├── resume_feedback.py # Resume analysis logic  
│   ├── requirements.txt   # Python dependencies  
│   ├── newapp.csv         # Skill analysis  
│   ├── venv/              # Python virtual environment (ignored in Git)  
│── pubspec.yaml           # Flutter dependencies  
│── README.md              # Documentation  
│── .gitignore             # Ignored files  
```  

---

## 🔧 Setup & Installation  

### 🖥 Step 1: Set Up & Run the Flask Backend  

1️⃣ Open VS Code & Navigate to the Backend  
```sh
cd backend
```
  
2️⃣ Create a Virtual Environment  
```sh
python -m venv venv
```

3️⃣ Activate the Virtual Environment  

**Windows:**  
```sh
venv\Scripts\activate
```  
**Mac/Linux:**  
```sh
source venv/bin/activate
```  

4️⃣ Install Dependencies  
```sh
pip install -r requirements.txt
```

5️⃣ Run the Flask Backend  
```sh
python newapp.py resume_feedback.py
```  

🔹 The backend will now run at **http://127.0.0.1:5002** and **5000**  

---

### 📱 Step 2: Set Up & Run the Flutter Frontend  

1️⃣ Navigate to the Flutter App  
```sh
cd ../  # Go back to the root folder
cd frontend
```

2️⃣ Install Flutter Dependencies  
```sh
flutter pub get
```

3️⃣ Run the Flutter App  
```sh
flutter run
```  

✅ Now both your **Flutter frontend** and **Flask backend** are running! 🚀  

---

## 🌐 API Endpoints  

### 📌 1. Resume Analysis  
**Endpoint:**  
```
POST /api/analyze
```
**Description:** Analyzes a PDF resume and provides detailed feedback.  

📥 **Request (Multipart Form Data):**  

| Parameter | Type  | Description          |
|-----------|-------|----------------------|
| resume    | File  | PDF resume file      |

📤 **Response Example:**  
```json
{
    "summary": {
        "score": 85,
        "likely_industry": "Software Development",
        "strengths": ["Strong technical skill set", "Effective use of action verbs"],
        "weaknesses": ["Lacks quantifiable achievements"]
    }
}
```

---

### 📌 2. Skill Analysis  
**Endpoint:**  
```
POST /api/skill
```
**Description:** Suggests the most suitable job based on the uploaded resume.  

📥 **Request:**  

| Parameter | Type  | Description         |
|-----------|-------|---------------------|
| resume    | File  | PDF resume file     |

---

## 📌 Environment Variables  
Make sure your **.env** file includes:  
```ini
FLASK_ENV=development
PORT=5000
```  

---

## 📜 Contribution Guide  

1️⃣ Fork the repository  
2️⃣ Create a new branch (`feature-new`)  
3️⃣ Commit your changes  
4️⃣ Push and submit a PR  

---

## 📜 License  
This project is licensed under the **MIT License**.  

---

## 🔑 Bypass Login (For Hackathon Evaluators)  
If you want to bypass the login part, use the following credentials:  

**User Email:** `abcd@gmail.com`  
**Password:** `qwerty1`  

---

