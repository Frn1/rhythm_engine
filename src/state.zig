const std = @import("std");

const Conductor = @import("conductor.zig");

const Time = @import("object.zig").Time;
const Position = @import("object.zig").Position;

/// The next object to process
next_object_to_process: usize = 0,

/// Current seconds per beat.
/// (`60/BPM`)
///
/// Should always be positive and NEVER 0 or lower.
/// (Unless the state is at its default un-processed state)
seconds_per_beat: Time = std.math.inf(f80),
/// Seconds to subtruct from the `current_time` when calculating `current_beat`.
seconds_offset: Time = 0,
/// Beats to add when calculating current_beat.
beats_offset: Time = 0,

/// Beats to subtract when calculating visual position.
visual_beats_offset: Time = 0,
/// Offset to add when calculating visual position.
visual_pos_offset: Position = 0,
/// Current scroll multiplier.
/// Used for calculating the current visual position.
scroll_mul: Position = 1.0,

/// Speed multiplier for every position in screen
screen_speed_mul: Position = 1.0,

/// The current beat.
/// It should **always** go higher or stop and **NEVER** go back in time.
/// (Unless the state is reset)
beat: Time = 0,

/// Recalculates the current beat.
///
/// **(It can only guarantee accuracy from the last object until the next object)**
inline fn updateBeat(self: *@This(), current_sec: Time) void {
    self.beat = self.convertSecondsToBeats(current_sec);
}

/// Calculate the visual position at `beat`.
///
/// **(It can only guarantee accuracy from the last object until the next object)**
pub inline fn calculateVisualPosition(self: @This(), beat: Time) Position {
    return @as(Position, @floatCast(beat - self.visual_beats_offset)) * self.scroll_mul + self.visual_pos_offset;
}

/// Convert `beats` into seconds
///
/// Inverse operation of `convertSecondsToBeats`.
///
/// **(It can only guarantee accuracy from the last object until the next object)**
pub inline fn convertBeatToSeconds(self: @This(), beats: f80) f80 {
    if (self.seconds_per_beat < 0 or !std.math.isNormal(self.seconds_per_beat)) {
        return self.seconds_offset;
    }
    const seconds = (beats - self.beats_offset) * self.seconds_per_beat + self.seconds_offset;
    if (seconds < self.seconds_offset) {
        return self.seconds_offset;
    }
    return seconds;
}

/// Convert `seconds` into beats.
///
/// Inverse operation of `convertBeatToSeconds`.
///
/// **(It can only guarantee accuracy from the last object until the next object)**
pub inline fn convertSecondsToBeats(self: @This(), seconds: Time) Time {
    if (self.seconds_per_beat < 0 or !std.math.isNormal(self.seconds_per_beat)) {
        return self.beats_offset;
    }
    if (seconds < self.seconds_offset) {
        return self.beats_offset;
    }
    const beats = (seconds - self.seconds_offset) / self.seconds_per_beat + self.beats_offset;
    return beats;
}

/// Process objects and update
pub fn update(self: *@This(), conductor: Conductor, current_seconds: Time, is_audio_thread: bool) void {
    self.updateBeat(current_seconds);
    for (conductor.objects[self.next_object_to_process..], self.next_object_to_process..) |object, i| {
        if (self.beat < object.beat) {
            break;
        }
        self.next_object_to_process = i + 1;
        object.process(object, self);
        if (is_audio_thread) {
            object.processAudio(object);
        }
        self.updateBeat(current_seconds);
    }
}
