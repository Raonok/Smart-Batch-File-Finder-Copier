# 🖥️ Smart-Batch-File-Copier

> **Smart PC Batch File Finder** is a **simple yet powerful Windows utility** for quickly locating and copying multiple files from a specified folder.  
> Perfect for anyone who needs to gather batch files (`.bat`) or any file types from one location to another, making bulk file management fast and easy!

---

<div align="center">

![Batch Finder Banner](https://img.shields.io/badge/Windows-Batch%20Utility-blue?style=for-the-badge&logo=windows)  
![Maintenance](https://img.shields.io/badge/Maintained-Yes-success?style=flat-square)
![Contributions-Welcome](https://img.shields.io/badge/Contributions-Welcome-brightgreen?style=flat-square)

</div>

---

## 🚦 How It Works

1. **Set your search root** (choose which folder to start searching from).
2. **List filenames you want to find** in `input.txt` (one per line).
3. **Run the script:** all matching files are copied into a new output folder, with detailed logs created for found & missing files.

---

## 📦 Folder Structure

```plaintext
BatchUtilityRoot/
│
├── Smart-Batch-File-Copier.bat                  # ← Main batch script
│
├── Input/
│   └── input.txt                   # ← List of filenames to search (one per line)
│
├── Output/
│   └── Found_Data_YYYY-MM-DD_HHMMSS/
│       ├── [copied files...]       # ← All found/copied files from this run
│
└── Log/
    ├── found_files.log             # ← Files that were found and copied
    └── not_found_files.log         # ← Files listed but not found


```

---

## ⚡ Features at a Glance

| Feature               | Description                                                                 |
|-----------------------|-----------------------------------------------------------------------------|
| 🔍 **Batch File Search**      | Instantly locate `.bat` or any file type in chosen folders/subfolders.    |
| 📂 **Custom Source Folder**   | Select any folder as your search starting point.                         |
| 🎯 **File Type Filtering**    | Filter search by extension (`.mkv`, `.doc`, etc.).                       |
| 🗃️ **Bulk Copy Function**     | Copy multiple found files to a destination in one go.                    |
| 💬 **Progress Feedback**      | Real-time status updates during search & copy.                           |
| ⏱️ **Fast Performance**       | Optimized for large directories.                                         |
| 🛡️ **Safe Operations**        | Preserves original files & structure.                                    |
| 📝 **Found Log**              | Lists all files successfully located and copied.                         |
| ❌ **Not Found Log**           | Details files that could not be found (if listed in `input.txt`).        |
| 📅 **Date-Time Output Folders**| Organizes copied files into timestamped output folders.                  |

---

### 🔧 **Setup & Usage**

#### 1️⃣ Set the Search Destination Folder

Open `Smart-Batch-File-Finder-Copier.bat` in your text editor. (Recomanded: Notepad++) 
**Edit this line** to set your search root:
```batch
set "SEARCH_ROOT=D:\"
```

#### 2️⃣ Add Filenames to Search

- Open `Input/input.txt` in your editor. (Recomanded: Notepad++)
- Add each filename (with or without extension), **one per line**.

#### 3️⃣ Run the Script

- **Double-click** `Smart-Batch-File-Finder-Copier.bat` or run it from Command Prompt.

The script will:
- Search for all listed files in the specified folder tree.
- Copy all found files into a **newly created Output folder**, named with date & time.
- Generate two logs:  
  - `found_files.log`
  - `not_found_files.log`
- Show progress feedback in the console.

---

## ✅ Example

Suppose `input.txt` contains:
```
123.mp3
new.MP4
notes.txt
data.doc
```
- The script will recursively search from `D:\` for these files and copy any it finds.

---

## 🙋‍♂️ Common Pitfalls & Tips

- **Don’t forget to set the correct `SEARCH_ROOT` path!**
- **List only names (and extensions) in `input.txt`, not full paths.**
- **Close `input.txt` before running the batch file to avoid access errors.**
- **Output folders are uniquely named; rerunning won’t overwrite previous results.**

---

> ⭐ **If you find this useful, give a Star!**  
> _Happy Bulk Managing!_

---

**© 2024 Md. Rofiqul Islam Raonok**
