Facter.add(:REMOTE_USER) do
  setcode do
    "FREMOTE_USER"
  end
end
Facter.add(:RHN_USER) do
  setcode do
    "FRHN_USER"
  end
end
Facter.add(:RHN_PASS) do
  setcode do
    "FRHN_PASS"
  end
end
