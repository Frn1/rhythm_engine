const Object = @This();

const std = @import("std");

const State = @import("state.zig");

fn emptyDestroy(_: @This(), _: std.mem.Allocator) void {}
fn emptyProcess(_: @This(), _: *State) void {}

pub const Time = f80;
pub const Position = f32;

/// Rhythmic time that the object would be hit at
beat: Time,

/// Priority used for sorting when objects have the same `beat`
///
/// Lower comes first while higher comes after
priority: i8 = 0,

/// Extra parameters for this object
parameters: *anyopaque = undefined,

/// Pointer to a function to destroy `parameters`
/// and everything created in init
///
/// Called when exiting
destroy: *const fn (self: @This(), allocator: std.mem.Allocator) void = &emptyDestroy,

/// Called when processing, loading and running gameplay.
/// Will run at the "perfect" time for the object.
///
/// For example, a BPM object would change the bpm in here,
/// while a BGM note object would do nothing in here (so it should be null).
process: *const fn (self: @This(), state: *State) void = emptyProcess,

/// Use this function to pointer cast the parameters
pub inline fn castParameters(comptime T: type, ptr: *anyopaque) *T {
    return @as(*T, @alignCast(@ptrCast(ptr)));
}

/// Use this function for sorting lists of objects
pub fn lessThanFn(_: void, lhs: @This(), rhs: @This()) bool {
    if (lhs.beat == rhs.beat) {
        return lhs.priority < rhs.priority;
    }
    return lhs.beat < rhs.beat;
}
