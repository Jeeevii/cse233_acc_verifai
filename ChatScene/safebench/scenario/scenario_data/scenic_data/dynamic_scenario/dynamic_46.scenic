'''The ego vehicle is driving on a highway, attempting to merge into a lane where multiple ACC vehicles are present. The ego vehicle accelerates and decelerates unpredictably while merging, forcing the ACC vehicle to make rapid speed adjustments and maintain a safe following distance.'''
Town = 'Town03'
param map = localPath(f'../maps/{Town}.xodr') 
param carla_map = Town
model scenic.simulators.carla.model
EGO_MODEL = "vehicle.lincoln.mkz_2017"

behavior AdvBehavior():
    while True:
        # Set a new random throttle value within the allowable range
        newThrottle = Range(0, globalParameters.OPT_MAX_THROTTLE)
        take SetThrottleAction(newThrottle)

        # Wait for a dynamically determined duration between throttle changes
        for _ in range(globalParameters.OPT_WAIT_THROTTLE_CHANGE):
            wait
        
        # Apply a random brake intensity
        take SetBrakeAction(Range(0, 0.5))

        # Wait for a dynamically determined duration before changing throttle again
        for _ in range(globalParameters.OPT_WAIT_BRAKE_PAUSE):
            wait

param OPT_MAX_THROTTLE = Range(0.5, 1)
param OPT_WAIT_THROTTLE_CHANGE = Range(10, 30)  # Duration between throttle adjustments
param OPT_WAIT_BRAKE_PAUSE = Range(10, 30)  # Duration to wait after braking before adjusting throttle again
# Identifying lane sections with a right lane moving in the same forward direction
laneSecsWithRightLane = []
for lane in network.lanes:
    for laneSec in lane.sections:
        if laneSec._laneToRight is not None and laneSec._laneToRight.isForward == laneSec.isForward:
            laneSecsWithRightLane.append(laneSec)

# Selecting a random lane section from identified sections for the ego vehicle
egoLaneSec = Uniform(*laneSecsWithRightLane)
egoSpawnPt = OrientedPoint in egoLaneSec.centerline

# Ego vehicle setup
ego = Car at egoSpawnPt,
    with regionContainedIn None,
    with blueprint EGO_MODEL
# Parameters for scenario elements
param OPT_GEO_BLOCKER_Y_DISTANCE = Range(0, 40)
param OPT_GEO_X_DISTANCE = Range(-8, 0)  # Offset for the agent in the opposite lane
param OPT_GEO_Y_DISTANCE = Range(10, 30)

# Setting up the parked car that blocks the ego's path
laneSec = network.laneSectionAt(ego)  # Assuming network.laneSectionAt(ego) is predefined in the geometry part
IntSpawnPt = OrientedPoint following roadDirection from egoSpawnPt for globalParameters.OPT_GEO_BLOCKER_Y_DISTANCE
Blocker = Car at IntSpawnPt,
    with heading IntSpawnPt.heading,
    with regionContainedIn None

# Setup for the motorcyclist who unexpectedly enters the scene
SHIFT = globalParameters.OPT_GEO_X_DISTANCE @ globalParameters.OPT_GEO_Y_DISTANCE
AdvAgent = Car at Blocker offset along IntSpawnPt.heading by SHIFT,
    with heading IntSpawnPt.heading + 180 deg,  # The agent is facing the opposite direction, indicating oncoming
    with regionContainedIn laneSec._laneToLeft,  # Positioned in the left lane, assuming it's the oncoming traffic lane
    with behavior AdvBehavior()