const std = @import("std");

const State = @import("../conductor.zig").State;
const Object = @import("../object.zig").Object;

const ScrollMultiplier = Object.Position;

const Parameters = ScrollMultiplier;

fn destroy(object: Object, allocator: std.mem.Allocator) void {
    allocator.destroy(Object.castParameters(Parameters, object.parameters));
}

fn process(object: Object, state: *State) void {
    const new_scroll = Object.castParameters(Parameters, object.parameters).*;
    state.visual_pos_offset = state.calculateVisualPosition(object.beat);
    state.visual_beats_offset = @floatCast(object.beat);
    state.scroll_mul = new_scroll;
}

/// Creates a Scroll object.
///
/// **Caller is responsible of calling `destroy` to destroy the object.**
///
/// **Note: This is NOT the same as calling `allocator.destroy`.**
pub fn create(allocator: std.mem.Allocator, beat: Object.Time, scroll: ScrollMultiplier) !Object {
    var object = Object{
        .beat = beat,
        .destroy = destroy,
        .process = process,
    };
    object.parameters = @ptrCast(try allocator.create(Parameters));
    Object.castParameters(Parameters, object.parameters).* = scroll;

    return object;
}
