Facter.add(:remoteuser) do
  setcode do
    "FREMOTE_USER"
  end
end
Facter.add(:rhnuser) do
  setcode do
    "FRHN_USER"
  end
end
Facter.add(:rhnpass) do
  setcode do
    "FRHN_PASS"
  end
end
