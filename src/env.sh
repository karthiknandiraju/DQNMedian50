cd /workspace

rm -f src/env/conda-explicit.txt
rm -f src/env/conda-list.txt
rm -f src/env/environment.yml
rm -f src/env/environment-from-history.yml

mkdir -p src/env

python3.7 --version > src/env/python-version.txt
python3.7 -m pip freeze > src/env/pip-freeze.txt
python3.7 -m pip list > src/env/pip-list.txt

cat > src/env/experiment-config.txt <<'EOF'
CARLA DQN Experiment Configuration
==================================

CARLA Version: 0.9.14

Experiments:
1. Epsilon Greedy
2. Median First
3. Median 50
4. Ensemble

Algorithm:
DQN + RND + Count-Based Exploration
Target Network
Replay Buffer
Adam Optimizer

Training Episodes: 500
Testing Episodes: 300
Maximum Episode Steps: 500

Learning Rate: 5e-5
Epsilon: 0.2
Gamma: 0.99
Batch Size: 64
Replay Capacity: 50000
Target Update Interval: 1000

RND Beta: 0.01
RND Learning Rate: 1e-4
RND Output Size: 64

Count Beta: 0.05
Count State Bin Size: 1.0

Realistic Traffic: Enabled
Traffic Vehicles: 2
Pedestrians: 2

Device: CUDA
Seed: 42
Convergence Threshold: 0.95
Convergence Window: 10
EOF

{
echo "Captured: $(date --iso-8601=seconds)"
echo

echo "===== CARLA VERSION ====="
echo "Expected CARLA version: 0.9.14"
echo "CARLA installation directory: /workspace/CARLA_0.9.14"

if [ -d /workspace/CARLA_0.9.14 ]; then
    ls -ld /workspace/CARLA_0.9.14
else
    echo "CARLA directory not found"
fi

echo
echo "===== CARLA PYTHON API ====="
export PYTHONPATH=/workspace/CARLA_0.9.14/PythonAPI/carla/dist/carla-0.9.14-py3.7-linux-x86_64.egg:/workspace:$PYTHONPATH

python3.7 - <<'PY'
try:
    import carla
    print("CARLA module path:", carla.__file__)
    print("CARLA client API imported successfully")
except Exception as e:
    print("CARLA import failed:", repr(e))
PY

echo
echo "===== CARLA SERVER FILES ====="
find /workspace/CARLA_0.9.14 -maxdepth 2 \
    \( -name "CarlaUE4.sh" -o -name "CarlaUE4" -o -name "CarlaUE4-Linux-Shipping" \) \
    -print 2>/dev/null

echo
echo "===== PYTHON ====="
python3.7 --version
which python3.7
echo "Virtual environment: ${VIRTUAL_ENV:-unknown}"

echo
echo "===== PIP ====="
python3.7 -m pip --version

echo
echo "===== PYTORCH ====="
python3.7 - <<'PY'
try:
    import torch
    print("PyTorch version:", torch.__version__)
    print("PyTorch CUDA version:", torch.version.cuda)
    print("CUDA available:", torch.cuda.is_available())
    if torch.cuda.is_available():
        print("GPU:", torch.cuda.get_device_name(0))
        print("GPU count:", torch.cuda.device_count())
except Exception as e:
    print("PyTorch check failed:", repr(e))
PY

echo
echo "===== NVIDIA GPU ====="
nvidia-smi

echo
echo "===== CUDA TOOLKIT ====="
nvcc --version 2>/dev/null || echo "nvcc is not installed or not in PATH"

echo
echo "===== OPERATING SYSTEM ====="
cat /etc/os-release 2>/dev/null
uname -a

echo
echo "===== CPU ====="
lscpu

echo
echo "===== MEMORY ====="
free -h

echo
echo "===== DISK ====="
df -h

echo
echo "===== PYTHONPATH ====="
echo "$PYTHONPATH"

echo
echo "===== CARLA PROCESS ====="
ps aux | grep -E "CarlaUE4|CARLA" | grep -v grep || echo "CARLA server is not currently running"

} > src/env/system-info.txt 2>&1

cat > src/env/run_command.txt <<'EOF'
cd /workspace

export PYTHONPATH=/workspace:$PYTHONPATH
export PYTHONPATH=/workspace/CARLA_0.9.14/PythonAPI/carla/dist/carla-0.9.14-py3.7-linux-x86_64.egg:$PYTHONPATH

mkdir -p /workspace/results/set4_v2

nohup python3.7 -m src.set4_v2 \
    --train-episodes 500 \
    --test-episodes 300 \
    --max-episode-steps 500 \
    --device cuda \
    --raw-learning-rate 5e-5 \
    --epsilon 0.2 \
    --gamma 0.99 \
    --batch-size 64 \
    --rnd-beta 0.01 \
    --rnd-learning-rate 1e-4 \
    --count-beta 0.05 \
    --count-state-bin-size 1.0 \
    --realistic-traffic \
    --num-traffic-vehicles 2 \
    --num-pedestrians 2 \
    --output-dir /workspace/results/set4_v2 \
    > /workspace/results/set4_v2/set4_v2.log 2>&1 &
EOF

ls -lh src/env
