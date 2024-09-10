const std = @import("std");

const State = @import("../conductor.zig").State;
const Object = @import("../object.zig").Object;

pub const Duration = Object.Time;

pub const Parameters = Duration;

fn destroy(object: Object, allocator: std.mem.Allocator) void {
    allocator.destroy(Object.castParameters(Parameters, object.parameters));
}

fn process(object: Object, state: *State) void {
    const duration = Object.castParameters(Parameters, object.parameters).*;
    state.seconds_offset = state.convertBeatToSeconds(
        object.beat + @as(f80, @floatCast(duration)),
    );
    state.beats_offset = object.beat;
    state.visual_pos_offset = state.calculateVisualPosition(object.beat);
    state.visual_beats_offset = object.beat;
}

/// Creates a Stop object.
///
/// **Caller is responsible of calling `destroy` to destroy the object.**
///
/// **Note: This is NOT the same as calling `allocator.destroy`.**
pub fn create(allocator: std.mem.Allocator, beat: Object.Time, duration: Duration) !Object {
    var object = Object{
        .beat = beat,
        .priority = -1,
        .destroy = destroy,
        .process = process,
    };
    object.parameters = @ptrCast(try allocator.create(Parameters));
    Object.castParameters(Parameters, object.parameters).* = duration;

    return object;
}
