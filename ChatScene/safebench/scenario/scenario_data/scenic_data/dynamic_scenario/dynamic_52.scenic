'''The ego vehicle is merging onto a busy highway, frequently changing lanes in front of an ACC vehicle. The ACC vehicle must adjust its speed continuously to maintain a safe following distance while also keeping an eye on other surrounding traffic.'''
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
        take SetSteerAction(globalParameters.OPT_ADV_STEER)  # Adjust steering dynamically.

        # Wait for a dynamically determined duration before changing steering again.
        for _ in range(globalParameters.OPT_WAIT_STEER):
            wait

param OPT_ADV_SPEED = Range(0, 20)  # Controls the initial speed of the adversarial car.
param OPT_ADV_DISTANCE = Range(0, 20)  # Specifies the distance at which the car begins its maneuver.
param OPT_ADV_STEER = Range(-1, 1)  # Range for steering actions.
param OPT_WAIT_STEER = Range(5, 20)  # Variable wait time before changing steering.
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
# Setup the leading vehicle's spawn point directly in front of the ego to simulate a slow-moving vehicle
param OPT_LEADING_DISTANCE = Range(0, 30)
param OPT_LEADING_SPEED = Range(1, 5)
LeadingSpawnPt = OrientedPoint following roadDirection from egoSpawnPt for globalParameters.OPT_LEADING_DISTANCE
LeadingAgent = Car at LeadingSpawnPt,
    with behavior FollowLaneBehavior(target_speed=globalParameters.OPT_LEADING_SPEED)

# Identifying the adjacent lane for the Adversarial Agent and setting its spawn point further in front
param OPT_GEO_Y_DISTANCE = Range(0, 30)
advLane = network.laneSectionAt(ego)._laneToRight.lane
IntSpawnPt = OrientedPoint following roadDirection from egoSpawnPt for globalParameters.OPT_GEO_Y_DISTANCE
projectPt = Vector(*advLane.centerline.project(IntSpawnPt.position).coords[0])
advHeading = advLane.orientation[projectPt]

# Spawn the Adversarial Agent
AdvAgent = Car at projectPt,
    with heading advHeading,
    with regionContainedIn None,
    with behavior AdvBehavior()