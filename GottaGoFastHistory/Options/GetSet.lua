function GottaGoFastHistory:GetHistory()
  return GottaGoFastHistory.db.profile.History;
end

function GottaGoFastHistory:SetHistory(val)
  GottaGoFastHistory.db.profile.History = val;
end
