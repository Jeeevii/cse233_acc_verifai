'''The ego vehicle approaches a signalized intersection and exhibits abnormal behavior such as abruptly stopping, reversing or accelerating late through a yellow light. This challenges the ACC enabled autonomous vehicle following behind. The goal is to test whether the Lead Vehicle can obey traffic signal rules while responding safely to the unpredictable behavior of an AV. The Lead Vehicle should not enter an intersection during a red light and must maintain a safe following distance. The scenario is inspired by California driving rules which require stopping at yellow lights when it is safe and never proceeding on red.'''

from controllers.lateral_control import LateralControl
from controllers.acc import AccControl

Town = 'Town03'
param map = localPath(f'../maps/{Town}.xodr')
param carla_map = Town
model scenic.simulators.carla.model

MODEL = "vehicle.tesla.model3"

param time_step = 1.0 / 10
param verifaiSamplerType = 'bo'

param EGO_SPEED = VerifaiRange(5, 15)
param STOP_BEHAVIOR_DISTANCE = VerifaiRange(10, 30)
param REVERSAL_ENABLED = True
param REVERSE_DISTANCE = VerifaiRange(1, 3)

param FOLLOWER_COUNT = 3
param FOLLOWER_GAP = 7

# Ego stops or reverses unpredictably at the intersection
behavior TrafficLightAttacker(id, dt, ego_speed, lane):
    long_control = AccControl(id, dt, ego_speed, True)
    lat_control = LateralControl(dt)
    acted = False
    while True:
        cars = [ego] + trailing
        b, t = long_control.compute_control(cars)
        s = lat_control.compute_control(self, lane)
        if not acted and self.position.distanceTo(intersection.position) < globalParameters.STOP_BEHAVIOR_DISTANCE:
            if globalParameters.REVERSAL_ENABLED:
                take SetThrottleAction(-0.5), SetBrakeAction(0.0)
            else:
                take SetThrottleAction(0.0), SetBrakeAction(1.0)
            acted = True
        else:
            take SetThrottleAction(t), SetBrakeAction(b), SetSteerAction(s)

# ACC-style follower behavior
behavior Follower(id, dt, ego_speed, lane):
    long_control = AccControl(id, dt, ego_speed, False)
    lat_control = LateralControl(dt)
    while True:
        cars = [ego] + trailing
        b, t = long_control.compute_control(cars)
        s = lat_control.compute_control(self, lane)
        take SetThrottleAction(t), SetBrakeAction(b), SetSteerAction(s)

# Select spawn lane approaching an intersection
intersection = Uniform(*network.intersections)
incomingLane = Uniform(*intersection.incomingLanes)
egoSpawnPt = OrientedPoint in incomingLane.centerline offset by -35
lane = network.laneSectionAt(egoSpawnPt)

id = 0
ego = Car at egoSpawnPt,
    with blueprint MODEL,
    with behavior TrafficLightAttacker(id, globalParameters.time_step, EGO_SPEED, lane)

# Trailing vehicles behind ego
trailing = []
for i in range(globalParameters.FOLLOWER_COUNT):
    offset = -10 - (i + 1) * globalParameters.FOLLOWER_GAP
    spawnPt = OrientedPoint following roadDirection from egoSpawnPt for offset
    follower = Car at spawnPt,
        with blueprint MODEL,
        with behavior Follower(i + 1, globalParameters.time_step, EGO_SPEED, lane)
    trailing.append(follower)

terminate when simulation().currentTime > 25 / globalParameters.time_step
