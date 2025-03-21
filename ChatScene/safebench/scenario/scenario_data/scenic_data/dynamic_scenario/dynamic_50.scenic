'''The ego vehicle is driving on a highway and performs a high-speed merge into a lane where an ACC vehicle is following. The ACC vehicle must react quickly to avoid tailgating and maintain a safe following distance by adjusting its speed.'''
Town = 'Town01'
param map = localPath(f'../maps/{Town}.xodr') 
param carla_map = Town
model scenic.simulators.carla.model
EGO_MODEL = "vehicle.lincoln.mkz_2017"

behavior AdvBehavior():
    while (distance to self) > 60:
        wait  # The adversarial car waits until it is within 60 meters of the ego vehicle.

    do FollowLaneBehavior(globalParameters.OPT_ADV_SPEED) until (
        distance to self < globalParameters.OPT_ADV_DISTANCE)

    while True:
        take SetThrottleAction(globalParameters.OPT_ADV_THROTTLE)  # Aggressively adjusts acceleration.
        
        # Wait for a dynamically determined duration
        for _ in range(globalParameters.OPT_WAIT_THROTTLE):
            wait

        take SetBrakeAction(globalParameters.OPT_ADV_BREAK)  # Aggressively adjusts braking.

        # Wait for a dynamically determined duration
        for _ in range(globalParameters.OPT_WAIT_BRAKE):
            wait

param OPT_ADV_SPEED = Range(0, 20)  # Controls the initial speed of the adversarial car.
param OPT_ADV_DISTANCE = Range(0, 20)  # Specifies the distance at which the car begins its aggressive maneuver.
param OPT_ADV_THROTTLE = Range(0, 1)  # Aggressive throttle range.
param OPT_ADV_BREAK = Range(0, 1)  # Determines the intensity of the braking.
param OPT_WAIT_THROTTLE = Range(5, 20)  # Variable wait time between throttle changes.
param OPT_WAIT_BRAKE = Range(5, 20)  # Variable wait time between brake applications.
# Collecting lane sections that have a left lane (opposite traffic direction) and no right lane (single forward road)
laneSecsWithLeftLane = []
for lane in network.lanes:
    for laneSec in lane.sections:
        if laneSec._laneToLeft is not None and laneSec._laneToRight is None:
            if laneSec._laneToLeft.isForward != laneSec.isForward:
                laneSecsWithLeftLane.append(laneSec)

# Selecting a random lane section that matches the criteria
egoLaneSec = Uniform(*laneSecsWithLeftLane)
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