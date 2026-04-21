from flask import Flask, jsonify, render_template
from flask_cors import CORS
import psutil # Import psutil for system information
import platform # To detect the operating system
import os # To check if a path exists
import subprocess
import getpass
#error trace
import traceback

app = Flask(__name__)
CORS(app) # Enable CORS for all routes

@app.route('/storage', methods=['GET'])
def storage():
    return render_template('pages/storage.html')

def notify(title, message):
    #osascript -e "display notification \"$2\" with title \"$1\""
    subprocess.run(['osascript', '-e', f'display notification "{message}" with title "{title}"'])

def get_directory_size(path):
    try:
        result = subprocess.run(['du', '-sk', path], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        size_kb = int(result.stdout.split()[0])
        return size_kb * 1024  # KB to Bytes
    except Exception:
        return 0

def get_disk_usage_path():
    # macOS only
    if platform.system() != "Darwin":
        return None, None

    data_volume = "/System/Volumes/Data"
    if os.path.exists(data_volume):
        return data_volume, "User Data Volume"
    else:
        return "/", "System Root Volume"


@app.route('/storage_stats/basic', methods=['GET'])
def get_basic_storage_stats():
    path_to_check, volume_label = get_disk_usage_path()
    if not path_to_check:
        return jsonify({"error": "This endpoint only supports macOS."}), 400

    try:
        disk_usage = psutil.disk_usage(path_to_check)
        response_data = {
            "volumeLabel": volume_label,
            "totalBytes": int(disk_usage.total),
            "usedBytes": int(disk_usage.used),
            "availableBytes": int(disk_usage.free)
        }
        return jsonify(response_data)
    except Exception as e:
        return jsonify({
            "error": "Failed to fetch storage statistics.",
            "details": str(e)
        }), 500

@app.route('/storage_stats/categorized', methods=['GET'])
def get_categorized_storage_stats():
    path_to_check, _ = get_disk_usage_path() #volume_label is not needed for categorized stats
    if not path_to_check:
        return jsonify({"error": "This endpoint only supports macOS."}), 400

    try:
        notify("MacStats", "Getting categorized storage statistics...")
        disk_usage = psutil.disk_usage(path_to_check)
        used_bytes = disk_usage.used

        username = getpass.getuser()
        user_home = os.path.expanduser(f"~{username}")
        notify("MacStats", "Getting Applications...")
        apps_bytes = get_directory_size("/Applications")
        notify("MacStats", "Getting Downloads")
        download_bytes = get_directory_size(os.path.join(user_home, "Downloads"))
        notify("MacStats", "Getting Documents")
        documents_bytes = get_directory_size(os.path.join(user_home, "Documents"))
        notify("MacStats", "Getting Photos")
        photos_bytes = get_directory_size(os.path.join(user_home, "Pictures"))
        notify("MacStats", "Getting iCloud Drive")
        icloud_bytes = get_directory_size(os.path.join(user_home, "Library"))
        system_data_bytes = (
            get_directory_size("/System") +
            get_directory_size("/Library") +
            get_directory_size("/private")
        )

        categorized_sum = apps_bytes + documents_bytes + photos_bytes + system_data_bytes + icloud_bytes
        other_bytes = used_bytes - categorized_sum
        if other_bytes < 0:
            other_bytes = 0

        categorized_data = {
            "Apps": apps_bytes,
            "Downloads" : download_bytes,
            "Documents": documents_bytes,
            "Photos": photos_bytes,
            "iCloud": icloud_bytes,
            "System Data": system_data_bytes,
            "Other": other_bytes
        }

        return jsonify({
            "categorizedUsage": categorized_data
        })
    except Exception as e:
        return jsonify({
            "error": "Failed to compute categorized usage.",
            "details": str(e),
            "trace": traceback.format_exc()
        }), 500


if __name__ == '__main__':
    # Run the Flask app on localhost:4637
    # Use debug=True for development to get more detailed error messages
    app.run(host='127.0.0.1', port=4637, debug=True)

