import os
import shutil
import argparse

def copy_cex_files(input_folder, output_folder):
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    for root, dirs, files in os.walk(input_folder):
        if root == input_folder:
            continue

        subfolder_name = os.path.basename(root)
        incr_value = 1  

        for file in files:
            if 'cex.csv' in file and 'no_cex' not in file:
                file_path = os.path.join(root, file)
                name, ext = os.path.splitext(file)
                new_file_name = f"{subfolder_name}_{incr_value}_{name}{ext}"
                output_file_path = os.path.join(output_folder, new_file_name)
                while os.path.exists(output_file_path):
                    incr_value += 1  
                    new_file_name = f"{subfolder_name}_{incr_value}_{name}{ext}"
                    output_file_path = os.path.join(output_folder, new_file_name)
                
                shutil.copy(file_path, output_file_path)
                print(f"Copied: {file_path} to {output_file_path}")
                incr_value += 1 

def main():
    parser = argparse.ArgumentParser(description="Copy 'cex.csv' files to an output folder.")
    parser.add_argument("-i", "--input_dir", type=str, required=True, help="Path to the input folder containing CSV files.")
    parser.add_argument("-o", "--output_dir", type=str, required=True, help="Path to the output folder to copy 'cex.csv' files to.")
    
    args = parser.parse_args()
    copy_cex_files(args.input_dir, args.output_dir)

if __name__ == "__main__":
    main()
