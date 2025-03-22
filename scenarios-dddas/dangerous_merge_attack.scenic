'''The ego vehicle begins a series of sudden merges on the highway, moving unpredictably in and out of lanes, forcing an ACC vehicle to react by adjusting its speed and maintaining a safe distance. The goal is to evaluate the ACC system's ability to handle sudden lane changes and maintain safe following distances on a busy highway.'''

Town = 'Town01'
param map = localPath(f'../maps/{Town}.xodr')
param carla_map = Town
model scenic.simulators.carla.model

EGO_MODEL = "vehicle.lincoln.mkz_2017"
FOLLOWER_MODEL = "vehicle.tesla.model3"

param OPT_ADV_SPEED        = Range(0, 20)
param OPT_ADV_DISTANCE     = Range(10, 30)
param OPT_LEADING_DISTANCE = Range(0, 30)
param OPT_LEADING_SPEED    = Range(1, 5)
param OPT_GEO_Y_DISTANCE   = Range(0, 30)
param FOLLOWER_COUNT       = 3
param FOLLOWER_GAP         = 7

# Adversarial vehicle follows lane, then merges in front of ego
behavior AdvBehavior():
    while (distance to self) > 60:
        wait
    do FollowLaneBehavior(target_speed=globalParameters.OPT_ADV_SPEED) until (distance to self) < globalParameters.OPT_ADV_DISTANCE
    do LaneChangeBehavior(laneSectionToSwitch=network.laneSectionAt(ego), target_speed=globalParameters.OPT_ADV_SPEED)

# Follower behavior (simple ACC approximation)
behavior FollowerBehavior(target_speed):
    do FollowLaneBehavior(target_speed=target_speed)

# Select lane sections with merge opportunities
laneSecsWithLeftLane = []
for lane in network.lanes:
    for laneSec in lane.sections:
        if laneSec._laneToLeft is not None and laneSec._laneToRight is None:
            if laneSec._laneToLeft.isForward != laneSec.isForward:
                laneSecsWithLeftLane.append(laneSec)

egoLaneSec = Uniform(*laneSecsWithLeftLane)
egoSpawnPt = OrientedPoint in egoLaneSec.centerline

# Ego vehicle (ACC-enabled)
ego = Car at egoSpawnPt,
    with regionContainedIn None,
    with blueprint EGO_MODEL,
    with behavior FollowerBehavior(target_speed=15)

# Lead vehicle placed ahead of ego
LeadingSpawnPt = OrientedPoint following roadDirection from egoSpawnPt for globalParameters.OPT_LEADING_DISTANCE
LeadingAgent = Car at LeadingSpawnPt,
    with behavior FollowLaneBehavior(target_speed=globalParameters.OPT_LEADING_SPEED)

# Spawn adversarial vehicle in adjacent lane ahead
advLane = network.laneSectionAt(ego)._laneToRight.lane
IntSpawnPt = OrientedPoint following roadDirection from egoSpawnPt for globalParameters.OPT_GEO_Y_DISTANCE
projectPt = Vector(*advLane.centerline.project(IntSpawnPt.position).coords[0])
advHeading = advLane.orientation[projectPt]

AdvAgent = Car at projectPt,
    with heading advHeading,
    with regionContainedIn None,
    with behavior AdvBehavior()

# Trailing vehicles behind ego
followers = []
for i in range(globalParameters.FOLLOWER_COUNT):
    offset = - (i + 1) * globalParameters.FOLLOWER_GAP
    followerPt = OrientedPoint following roadDirection from egoSpawnPt for offset
    follower = Car at followerPt,
        with blueprint FOLLOWER_MODEL,
        with behavior FollowerBehavior(target_speed=15)
    followers.append(follower)
