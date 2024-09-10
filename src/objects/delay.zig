const std = @import("std");

const State = @import("../conductor.zig").State;
const Object = @import("../object.zig").Object;

pub const Stop = @import("stop.zig");

/// Creates a Delay object.
/// This is just a Stop object with the priority set to 1.
///
/// **Caller is responsible of calling `destroy` to destroy the object.**
///
/// **Note: This is NOT the same as calling `allocator.destroy`.**
pub fn create(allocator: std.mem.Allocator, beat: Object.Time, duration: Stop.Duration) !Object {
    var object = Stop.create(allocator, beat, duration);
    object.priority = 1;

    return object;
}
