#!/usr/bin/env python3
import argparse
import os
import matplotlib.pyplot as plt

def main():
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Plot plant growth data from CLI arguments")
    parser.add_argument("--plant", type=str, required=True, help="Plant name")
    parser.add_argument("--height", nargs="+", type=float, required=True, help="Height data (cm) over time")
    parser.add_argument("--leaf_count", nargs="+", type=int, required=True, help="Leaf count data over time")
    parser.add_argument("--dry_weight", nargs="+", type=float, required=True, help="Dry weight data (g) over time")
    
    args = parser.parse_args()

    # Extract parameters
    plant = args.plant
    height_data = args.height
    leaf_count_data = args.leaf_count
    dry_weight_data = args.dry_weight

    # Ensure output directory exists inside Q4
    output_dir = os.path.join("Q4", plant)
    os.makedirs(output_dir, exist_ok=True)

    # Debug: Print where images will be saved
    print(f"Saving plots in: {output_dir}")

    # Scatter plot: Height vs Leaf Count
    plt.figure(figsize=(10, 6))
    plt.scatter(height_data, leaf_count_data, color='b')
    plt.title(f'Height vs Leaf Count for {plant}')
    plt.xlabel('Height (cm)')
    plt.ylabel('Leaf Count')
    plt.grid(True)
    plt.savefig(os.path.join(output_dir, f"{plant}_scatter.png"))
    plt.close()

    # Histogram: Dry Weight distribution
    plt.figure(figsize=(10, 6))
    plt.hist(dry_weight_data, bins=5, color='g', edgecolor='black')
    plt.title(f'Histogram of Dry Weight for {plant}')
    plt.xlabel('Dry Weight (g)')
    plt.ylabel('Frequency')
    plt.grid(True)
    plt.savefig(os.path.join(output_dir, f"{plant}_histogram.png"))
    plt.close()

    # Line plot: Height over time
    weeks = [f"Week {i+1}" for i in range(len(height_data))]
    plt.figure(figsize=(10, 6))
    plt.plot(weeks, height_data, marker='o', color='r')
    plt.title(f'{plant} Height Over Time')
    plt.xlabel('Time')
    plt.ylabel('Height (cm)')
    plt.grid(True)
    plt.savefig(os.path.join(output_dir, f"{plant}_line_plot.png"))
    plt.close()

    # Print confirmation
    print(f"Generated plots for {plant} and saved in {output_dir}")

if __name__ == "__main__":
    main()
