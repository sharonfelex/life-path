# LIFE PATH

LIFE PATH is a smart ambulance routing system designed to reduce emergency response time by planning routes early and guiding traffic clearance at a lane level.

Unlike existing systems that react only when an ambulance reaches a traffic signal, LIFE PATH starts when a customer books an ambulance. The system finds the nearest hospital, calculates the fastest route using traffic data, and prepares traffic junctions in advance.

## How It Works

LIFE PATH operates using three coordinated components:

1. **Customer App**
   - Customer books an ambulance
   - Nearest hospital is selected
   - Fastest route is calculated based on traffic

2. **Ambulance Unit**
   - Receives the assigned route
   - Streams live GPS location and movement data
   - Acts as the authoritative source during the emergency

3. **Traffic Junction Unit**
   - Receives route and ambulance location
   - Determines exactly which lane must be cleared
   - Displays clear, lane-level instructions on a screen
   - Aligns traffic signals for smooth passage

Instead of showing vague directions, junctions display the exact lane that needs to be cleared based on the ambulance’s route.

## Why LIFE PATH Is Different

- Starts from **customer booking**, not late detection
- Uses **fastest route**, not just shortest distance
- Alerts **all junctions on the route in advance**
- Provides **lane-level clearance instructions**
- Combines human guidance with automated control
- Designed as a complete, deployable system

## Project Structure

