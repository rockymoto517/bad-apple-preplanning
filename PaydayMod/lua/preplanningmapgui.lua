function PrePlanningMapGui:custom_draw_point(x, y)
    local px = (x - self._grid_panel:x()) / self._grid_panel:w()
    local py = (y - self._grid_panel:y()) / self._grid_panel:h()
    local sync_step = 10000
    px = math.round(px * sync_step) / sync_step
    py = math.round(py * sync_step) / sync_step
    px = math.clamp(px, 0, 1)
    py = math.clamp(py, 0, 1)
    local peer_id = managers.network:session():local_peer():id()
    -- Don't sync with other peers, only sync with self so there's less overhead
    self:sync_draw_point(peer_id, px, py)
end
Hooks:PostHook(PrePlanningMapGui, "update", "draw_update",
function(self, t, dt)
    Hooks:Call("draw_bad_apple", t, dt)
end)