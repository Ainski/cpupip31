"""
Python script to combine all Verilog files from project_1\project_1.srcs\sources_1\new into a single file.
"""
import os
import glob

def combine_verilog_files():
    # Define source and destination paths
    source_dir = r"E:\Homeworks\cpupip31\project_1\project_1.srcs\sources_1\new"
    output_file = r"E:\Homeworks\cpupip31\combined_sources_python.txt"
    
    # Get all .v files from the source directory
    verilog_files = glob.glob(os.path.join(source_dir, "*.v"))
    
    # Sort the files to ensure consistent order
    verilog_files.sort()
    
    # Open the output file for writing
    with open(output_file, 'w', encoding='utf-8') as outfile:
        # Write header information
        outfile.write("# Combined content from project_1\\project_1.srcs\\sources_1\\new\n\n")
        outfile.write("This file contains all the Verilog source files from the sources_1/new directory combined into a single file.\n\n")
        outfile.write("---\n\n")
        
        # Process each Verilog file
        for file_path in verilog_files:
            filename = os.path.basename(file_path)
            
            # Write a header for each file
            outfile.write(f"## {filename}\n")
            
            # Read and write the content of the file
            with open(file_path, 'r', encoding='utf-8') as infile:
                content = infile.read()
                outfile.write(content)
                
            # Add some separation between files
            outfile.write("\n\n---\n\n")
    
    print(f"Successfully combined {len(verilog_files)} files into {output_file}")
    print("Files included:")
    for file_path in verilog_files:
        print(f"  - {os.path.basename(file_path)}")

if __name__ == "__main__":
    combine_verilog_files()