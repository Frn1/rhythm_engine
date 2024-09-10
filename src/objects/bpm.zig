const std = @import("std");

const State = @import("../conductor.zig").State;
const Object = @import("../object.zig").Object;

pub const BeatsPerMinute = Object.Time;

pub const Parameters = BeatsPerMinute;

fn destroy(object: Object, allocator: std.mem.Allocator) void {
    allocator.destroy(Object.castParameters(Parameters, object.parameters));
}

fn process(object: Object, state: *State) void {
    const new_bpm = Object.castParameters(Parameters, object.parameters).*;
    if (state.seconds_per_beat < 0 or !std.math.isNormal(state.seconds_per_beat)) {
        state.seconds_offset = 0;
    } else {
        state.seconds_offset = state.convertBeatToSeconds(object.beat);
    }
    state.beats_offset = object.beat;
    state.seconds_per_beat = 60 / new_bpm;
}

/// Creates a BPM object.
///
/// **Caller is responsible of calling `destroy` to destroy the object.**
///
/// **Note: This is NOT the same as calling `allocator.destroy`.**
pub fn create(allocator: std.mem.Allocator, beat: Object.Time, bpm: BeatsPerMinute) !Object {
    var object = Object{
        .beat = beat,
        .priority = 127,
        .destroy = destroy,
        .process = process,
    };
    object.parameters = @ptrCast(try allocator.create(Parameters));
    Object.castParameters(Parameters, object.parameters).* = bpm;

    return object;
}
