'''
Be Aware of Your Surroundings
To drive safely, you need to know what is around you. This helps you
make good decisions and react to hazards on the road. This image shows
the areas around your vehicle.
• Green: Ahead of you.
• Blue: Next to you.
• Yellow: Blinds spots.
• Red: Behind you.
Scan Your Surroundings
To give yourself time to react, avoid last minute
moves and hazards, always keep your eyes moving and scan the road at
least 10 seconds ahead of your vehicle.
Tailgating (Following Too Closely)
Tailgating makes it harder for you to see the road ahead because the
vehicle in front of you blocks your view. You will not have enough time to
react if the driver in front of you brakes suddenly. Use the three-second
rule to ensure a safe following distance and avoid a collision. Following
other vehicles at a safe distance gives you enough time to react if
another driver makes a mistake.
If a vehicle merges in front of you too closely, take your foot off the
accelerator. This creates space between you and the vehicle ahead.
Create more space in front of your vehicle when:
• A tailgater is behind you. Maintain your course and speed. Then,
when safe to do so, merge right to change into another lane and allow
the tailgater to pass.
• Following motorcyclists on metal surfaces (bridge gratings, railroad
tracks, etc.), and gravel.
Know What Is at Your Side
Be aware of what is on each side of you. To maintain enough space to
maneuver safely and react to other drivers:
• Do not stay in another driver’s blind spot.
• Avoid driving directly alongside other vehicles.
• Make space for vehicles entering freeways, even if you have the rightof-way. Be ready for rapid changes and watch for signals from other
drivers.
• Keep space between your vehicle and parked vehicles.
• Look both ways, even at intersections where traffic has a red light or
stop sign.
Blind Spots
Every vehicle has blind spots. These
are areas around the vehicle that
a driver cannot see when looking
straight ahead or using the mirrors. For
most vehicles, the blinds spots are at
the sides slightly behind the driver.
To check your blind spots, look over
your right and left shoulders out of
your side windows. Only turn your head when you look. Do not turn your
whole body or steering wheel. Check your blind spots before you:
• Change lanes.
• Turn at an intersection.
• Merge with traffic.
• Back up.
• Leave a parking space.
• Parallel park.
• Pull out from the curb.
• Open your car door
'''

from controllers.lateral_control import LateralControl
from controllers.acc import AccControl

Town = 'Town04'
param map = localPath(f'../maps/{Town}.xodr')
param carla_map = Town
model scenic.simulators.carla.model

MODEL = "vehicle.tesla.model3"
param time_step = 1.0 / 10
param AV_SPEED = VerifaiRange(10, 20)

# ACC behavior
behavior Follower(id, dt, speed, lane):
    long_control = AccControl(id, dt, speed, False)
    lat_control = LateralControl(dt)
    while True:
        b, t = long_control.compute_control([ego])
        s = lat_control.compute_control(self, lane)
        take SetThrottleAction(t), SetBrakeAction(b), SetSteerAction(s)

# Spawn lane and ego
laneSec = Uniform(*network.laneSections)
start = OrientedPoint in laneSec.centerline offset by -50
lane = network.laneSectionAt(start)

ego = Car at start,
    with blueprint MODEL,
    with behavior Follower(0, time_step, AV_SPEED, lane)