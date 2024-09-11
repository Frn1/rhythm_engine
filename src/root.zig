pub const Object = @import("object.zig");
pub const Conductor = @import("conductor.zig");
pub const State = @import("state.zig");

pub const Objects = struct {
    pub const Bpm = @import("objects/bpm.zig");
    pub const Stop = @import("objects/stop.zig");
    pub const Delay = @import("objects/delay.zig");
    pub const Scroll = @import("objects/scroll.zig");
};
