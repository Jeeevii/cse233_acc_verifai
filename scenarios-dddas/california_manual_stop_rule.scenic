'''
Traffic Control
When at or approaching traffic signals or signs, yield to pedestrians,
bicyclists, and other nearby vehicles that may have the right-of-way. See
Right of Way Rules: Who Goes First, in this section.
Traffic Signals
Solid Red Light
A red traffic signal light means STOP. You can turn right at a red
light, if:
• There is not a NO TURN ON RED sign posted.
• You stop at the stop or limit line, yield for pedestrians, and turn
when it is safe.
Red Arrow
A red arrow means STOP. Do not turn at a red arrow. Remain
stopped until a green traffic signal light or green arrow appears.
Flashing Red Light
A flashing red signal light means STOP. After stopping, you may
go when it is safe.
Solid Yellow Light
A yellow traffic signal light means CAUTION. The light is about
to turn red. When you see a yellow traffic signal light, stop, if you
can do so safely. If you cannot stop safely, cautiously cross the
intersection.
Yellow Arrow
A yellow arrow means the protected turning time is ending. The
signal will change soon. If you cannot stop safely or you are
already in the intersection, cautiously complete your turn. Pay
attention to the next signal. It could be a:
• Green or red traffic signal light.
• Red arrow.
Flashing Yellow Light
A flashing yellow traffic signal light is a warning to PROCEED
WITH CAUTION. Slow down and be alert. You do not need to
stop.
Flashing Yellow Arrow
You can turn, but your turn is not protected from other traffic.
Proceed to turn left after yielding to oncoming traffic and
proceed with caution.
Solid Green Light
A green traffic signal light means GO. You should still stop for
any vehicle, bicyclist, or pedestrian in the intersection. Only
proceed if you have enough space without creating a danger to
any oncoming vehicle, bicyclist, or pedestrian. Do not enter the
intersection if you cannot get completely across before the traffic
signal light turns red.
Green Arrow
A green arrow means GO in the direction the arrow is pointing.
The green arrow allows you to make a protected turn.
Oncoming vehicles are stopped by a red traffic signal light.
Traffic Light Not Working
When a traffic light is not working, stop as if the intersection
is controlled by STOP signs in all directions. Then proceed
cautiously when it is safe to do so.
Pedestrian Signals or Signs
WALK or Walking Person
You may cross the street.
DON’T WALK or Raised Hand
You may not cross the street.
Flashing DON’T WALK or Flashing Raised Hand
Do not start crossing the street. The traffic signal light is about
to change. Drivers must yield to pedestrians, even if the DON’T
WALK light is flashing.
Numbers
The numbers count down the seconds left for crossing the
street.
Diagonal Crossing
These are crisscross and diagonal crosswalks that allow
pedestrians to cross the intersection in any direction at the
same time. Cross only when the WALK signal allows it.
Sounds
Sounds such as beeping, chirping, or verbal messages help blind
or visually impaired pedestrians cross the street.
Pedestrian Push Button
This is used to activate the WALK or Walking Person signal.
No Pedestrian Signals
If there are no pedestrian signals, obey the vehicle traffic signals.
Signs
Obey all warning signs regardless of their shape or color.
STOP Sign
Make a full stop before entering the crosswalk or at the limit
line. If there is no limit line or crosswalk, stop before entering the
intersection. Check traffic in all directions before proceeding.
Red YIELD Sign
Slow down and be ready to stop to let any vehicle, bicyclist, or
pedestrian pass before you proceed.
'''

from controllers.lateral_control import LateralControl
from controllers.acc import AccControl

Town = 'Town03'
param map = localPath(f'../maps/{Town}.xodr')
param carla_map = Town
model scenic.simulators.carla.model

MODEL = "vehicle.tesla.model3"
param time_step = 1.0 / 10
param AV_SPEED = VerifaiRange(5, 12)
param SIGNAL_DISTANCE = VerifaiRange(10, 30)

behavior SignalFollower(id, dt, speed, lane):
    long_control = AccControl(id, dt, speed, False)
    lat_control = LateralControl(dt)
    while True:
        b, t = long_control.compute_control([ego])
        s = lat_control.compute_control(self, lane)
        if self.position.distanceTo(intersection.position) < globalParameters.SIGNAL_DISTANCE:
            take SetThrottleAction(0.0), SetBrakeAction(1.0), SetSteerAction(s)
        else:
            take SetThrottleAction(t), SetBrakeAction(b), SetSteerAction(s)

intersection = Uniform(*network.intersections)
incomingLane = Uniform(*intersection.incomingLanes)
start = OrientedPoint in incomingLane.centerline offset by -35
lane = network.laneSectionAt(start)

ego = Car at start,
    with blueprint MODEL,
    with behavior SignalFollower(0, time_step, AV_SPEED, lane)