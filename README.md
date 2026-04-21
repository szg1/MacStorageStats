# MacStats

MacStats is a lightweight macOS utility that provides both basic and categorized storage statistics through a clean, macOS-inspired web interface.

It is built with Python (Flask) for the backend and HTML/Tailwind CSS for the frontend.

## Features

- **Fast Retrieval**: Quickly fetches basic storage information including total, used, and available space.
- **Categorized Breakdown**: Analyzes and categorizes your storage usage into Apps, Documents, Downloads, Photos, iCloud, System Data, and Other.
- **Clean UI**: A responsive, macOS-like user interface powered by Tailwind CSS.
- **Automated Lifecycle**:
  - `setup.sh` handles dependencies and environment setup.
  - `run.sh` launches the backend and opens a Safari tab automatically.
  - Shutting down the Safari tab automatically cleans up and shuts down the backend process.

## Prerequisites

- **macOS** (This application uses macOS-specific features like `osascript` and specific volume paths)
- **Python 3**
- **Safari** (The runner script uses AppleScript to detect when the Safari tab closes to stop the backend)

## Installation & Setup

You can use the provided setup script which will check requirements (Python, Homebrew, pip), download the latest files from the repository, and start the app.

```bash
bash setup.sh
```

Alternatively, you can manually set it up:
1. Create a virtual environment: `python3 -m venv .venv`
2. Activate it: `source .venv/bin/activate`
3. Install dependencies: `pip install -r requirements.txt`
4. Run the launcher: `bash run.sh`

## Usage

When you run the project (via `setup.sh` or `run.sh`), the script automatically handles everything:
1. It launches the backend server in the background.
2. It opens a new Safari tab pointing to the storage statistics dashboard.
3. Once you are done, simply close the Safari tab. The script will detect this and safely shut down the backend server.

## API Endpoints

The backend provides the following endpoints:

- `GET /storage`: Serves the frontend HTML dashboard.
- `GET /storage_stats/basic`: Returns basic volume label, total, used, and available bytes.
- `GET /storage_stats/categorized`: Computes and returns a categorized breakdown of storage usage across various system and user directories.
