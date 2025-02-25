import matplotlib.pyplot as plt
import pandas as pd
import os
import argparse
import re

parser = argparse.ArgumentParser(description="Given folder with CSV files, will plot them into sub folder /graphs")
parser.add_argument("-i", "--input_dir", type=str, required=True, help="Path to the input folder containing CSV files.")
args = parser.parse_args()

input_dir = args.input_dir
output_dir = os.path.join(input_dir, 'graphs')

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

vehicle_pairs = ['c0_c1', 'c1_c2', 'c2_c3']  # plotting data
threshold_distance = 5  # threshold for violation/crash

for file_name in os.listdir(input_dir):
    if file_name.endswith(".csv"):
        file_path = os.path.join(input_dir, file_name)
        df = pd.read_csv(file_path)
        df.columns = ['time', 'c0_c1', 'c1_c2', 'c2_c3', 'p1', 'p2', 'p3', 'p4']
        # extract numeric positions from 'p1' column
        df['c0_position'] = df['p1'].apply(lambda x: float(re.findall(r"[-+]?\d*\.\d+|\d+", str(x))[0]) if re.findall(r"[-+]?\d*\.\d+|\d+", str(x)) else None)

        # calculate speed (dx/dt) for ego (c0)
        df['c0_speed'] = df['c0_position'].diff() / df['time'].diff()

        # inital random distance of ego 
        initial_pos = df['c0_position'].iloc[0] if not pd.isna(df['c0_position'].iloc[0]) else None
        legend_title = f"Initial position of ego (c0): {initial_pos:.2f}m"
        # 5-second intervals for speed 
        df_filtered = df[df['time'] % 5 == 0]
        fig, ax1 = plt.subplots(figsize=(10, 6))

        lines = []
        labels = []
        for pair in vehicle_pairs:
            line, = ax1.plot(df['time'], df[pair], label=f'Distance between {pair}')
            lines.append(line)
            labels.append(f'Distance between {pair}')
        threshold_line = ax1.axhline(y=threshold_distance, color='red', linestyle='--', label=f'Threshold: {threshold_distance}m')
        lines.append(threshold_line)
        labels.append(f'Threshold: {threshold_distance}m')

        ax1.set_xlabel('Time (or Iterations)')
        ax1.set_ylabel('Distance (m)')
        ax1.set_title(f'Distance vs Time for {file_name}')
        ax1.grid()

        ax2 = ax1.twinx()
        speed_line, = ax2.plot(df_filtered['time'], df_filtered['c0_speed'], color='lightblue', linestyle='dotted', marker='.', label='Ego Car (c0) Speed')

        lines.append(speed_line)
        labels.append('Ego Car (c0) Speed')
        ax1.legend(lines, labels, title=legend_title)

        output_path = os.path.join(output_dir, f'{file_name.replace(".csv", ".png")}')
        plt.savefig(output_path)
        #plt.show()
        plt.close()

        print(f"Plotted distance and speed graph for {file_name} at {output_path}")

print("Finished processing and plotting all files.")
