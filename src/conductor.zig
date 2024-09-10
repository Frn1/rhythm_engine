pub const Conductor = @This();

const std = @import("std");

const Object = @import("object.zig");
const State = @import("state.zig");

objects: []Object,

pub fn sortObjects(self: Conductor) void {
    std.sort.heap(
        Object,
        self.objects,
        self,
        Object.lessThanFn,
    );
}

pub fn destroyObjects(self: *Conductor, allocator: std.mem.Allocator) void {
    for (self.objects) |object| {
        object.destroy(object, allocator);
    }
    allocator.free(self.objects);
}

/// Calculate seconds and positions for each object in this conductor
///
/// The arguments (except for self) are optional.
pub fn calculateSecondsAndPositions(
    self: @This(),
    output_seconds: ?[]Object.Time,
    output_positions: ?[]Object.Position,
) error{OutputTooSmall}!void {
    if (output_seconds != null and self.objects.len > output_seconds.?.len) {
        return error.OutputTooSmall;
    } else if (output_positions != null and self.objects.len > output_positions.?.len) {
        return error.OutputTooSmall;
    }

    var state = State{};

    for (self.objects, 0..self.objects.len) |object, index| {
        const time = state.convertBeatToSeconds(object.beat);
        if (output_seconds != null) {
            output_seconds.?[index] = time;
        }
        state.update(self, time, false);
        const position = state.calculateVisualPosition(object.beat);
        if (output_positions != null) {
            output_positions.?[index] = position;
        }
    }
}

/// `calculateSecondsAndPositions` but using the allocator to automatically create the output.
///
/// **The caller is required to handle freeing the memory created.**
pub fn calculateSecondsAndPositionsAlloc(
    self: @This(),
    allocator: std.mem.Allocator,
) !struct {
    seconds: []Object.Time,
    positions: []Object.Position,
} {
    const output_seconds = try allocator.alloc(Object.Time, self.objects.len);
    const output_positions = try allocator.alloc(Object.Position, self.objects.len);

    // Since we allocated the outputs to be the size of the objects,
    // this can't fail for that reason
    self.calculateSecondsAndPositions(
        output_seconds,
        output_positions,
    ) catch |err| switch (err) {
        error.OutputTooSmall => undefined,
        else => return err,
    };

    return .{ .seconds = output_seconds, .positions = output_positions };
}

/// Calculate only the seconds for each object in this conductor
pub fn calculateSeconds(self: @This(), output: []Object.Time) !void {
    return try self.calculateSecondsAndPositions(output, null);
}

/// `calculateSeconds` but using the allocator to automatically create the output.
///
/// **The caller is required to handle freeing the memory created.**
pub fn calculateSecondsAlloc(self: @This(), allocator: std.mem.Allocator) ![]f80 {
    const output = try allocator.alloc(Object.Time, self.objects.len);

    // Since we allocated the output to be the size of the objects,
    // this can't fail for that reason
    self.calculateSeconds(output) catch |err| switch (err) {
        error.OutputTooSmall => undefined,
        else => return err,
    };

    return output;
}

/// Calculate only the position for each object in this conductor
pub fn calculatePositions(self: @This(), output: []Object.Position) !void {
    return try self.calculateSecondsAndPositions(null, output);
}

pub fn calculatePositionsAlloc(self: @This(), allocator: std.mem.Allocator) ![]Object.Position {
    const output = try allocator.alloc(Object.Position, self.objects.len);

    // Since we allocated the output to be the size of the objects,
    // this can't fail for that reason
    self.calculatePositions(output) catch |err| switch (err) {
        error.OutputTooSmall => undefined,
        else => return err,
    };

    return output;
}
