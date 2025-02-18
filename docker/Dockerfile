FROM python:3.10-slim-buster

WORKDIR /usr/local/bin

# Install required Python packages
RUN python3 -m pip install -U openpyxl pandas

# Copy the Python script into the container
COPY get_score.py .

# Ensure the script has the correct shebang and is executable
RUN chmod +x get_score.py

# Install git
RUN apt-get update && apt-get install -y git && apt-get clean

# Clone the public GitHub repository
RUN git clone https://github.com/CBIIT/MIDI_validation_script.git /usr/local/bin/MIDI_validation_script

# Create variable for the dicom tools needed
ENV PATH="$PATH:MIDI_validation_script/software/dicom3tools_linux/bin"

# Change permissions recursively for the submodule directory 
RUN chmod -R +x MIDI_validation_script

# Copy the Python module into the container that will generate a config.json
COPY answer_preparer.py /usr/local/bin/MIDI_validation_script/modules/answer_preparer.py

# Ensure the script has the correct shebang and is executable
RUN chmod +x /usr/local/bin/MIDI_validation_script/modules/answer_preparer.py

# Install Python dependencies from requirements.txt
RUN pip install --upgrade pip 

# Install the requirements with retry logic
RUN --mount=type=cache,target=/root/.cache/pip \
    for i in $(seq 1 5); do \
        pip install --no-cache-dir -r /usr/local/bin/MIDI_validation_script/requirements.txt && break || sleep 10; \
    done