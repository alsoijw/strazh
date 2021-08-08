describe Strazh::DimmingHash do
  it "dimming keys" do
    hs = Strazh::DimmingHash{ "a" => 3, "b" => 1 }
    [ hs["a"]?, hs["b"]?, hs["c"]? ].should eq [ 3, 1, nil ]

    hs = hs.wrap

    hs["a"] = 2
    [ hs["a"]?, hs["b"]?, hs["c"]? ].should eq [ 2, 1, nil ]

    hs["a"] = 4
    hs1 = hs.parrent
    [ hs["a"], hs1 ? hs1["a"] : 0 ].should eq [ 4, 3 ]
  end
end
