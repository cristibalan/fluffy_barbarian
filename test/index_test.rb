require File.join(File.dirname(__FILE__), "test_helper")

describe "FluffyBarbarian::Index, parsing" do
  [
    ["# Mmm pie\n  2009 10 01, 2010 04 12\n  tags:   brazil,   sao paulo\n  categories: food",
      [
        { :title => "Mmm pie", :autoslug => "mmm-pie", :slug => "mmm-pie",
          :url => "/2009/10/01/mmm-pie",
          :happened_on => "2009-10-01", :written_on => "2010-04-12",
          :tags => ["brazil", "sao paulo"],
          :categories => ["food"] }
      ]
    ],

    ["#    Mmm more pie\n  2009 10 15   \n  pie:   brazil, sao paulo   \nslug: moar-pie\n  categories: food, moar",
      [
        { :title => "Mmm more pie", :autoslug => "mmm-more-pie", :slug => "moar-pie",
          :url => "/2009/10/15/moar-pie",
          :happened_on => "2009-10-15", :written_on => "2009-10-15",
          :categories => ["food", "moar"],
          :pie => "brazil, sao paulo" }
      ]
    ],

    ["# Mmm pie\n  2009 10     01, 2010    04 12\n  tags:   sao paulo\n  categories: no way, jose\n" +
     "#    Mmm more pie\n  2009 10 15   \n  pie: brazil       , sao       paulo",
      [
        { :title => "Mmm pie", :slug => "mmm-pie", :autoslug => "mmm-pie",
          :url => "/2009/10/01/mmm-pie",
          :happened_on => "2009-10-01", :written_on => "2010-04-12",
          :tags => ["sao paulo"],
          :categories => ["no way", "jose"]},

        { :title => "Mmm more pie", :slug => "mmm-more-pie", :autoslug => "mmm-more-pie",
          :url => "/2009/10/15/mmm-more-pie",
          :happened_on => "2009-10-15", :written_on => "2009-10-15",
          :pie => "brazil , sao paulo" }
      ],
    ]

  ].each_with_index do |(raw, parsed), i|
    it "should parse: take #{i}" do
      FluffyBarbarian::Index.new.parsed(raw).should == parsed
    end
  end

end

describe "FluffyBarbarian::Index, finding" do
  it "should find all posts on disk" do
    index = FluffyBarbarian::Index.new(File.join(FIXTURES, "content/_posts"))

    index.on_disk.collect{|f| f[:title]}.should ==
      ["I'm içi, todo bem?", "Mmm more pie", "Mmm pie", "Möré weîrd stuff!"]

    index.on_disk.first[:extname].should == ".mkd"
  end

  it "should know if it's sane" do
    index = FluffyBarbarian::Index.new(File.join(FIXTURES, "content/_posts"))
    index.should.not.be.sane
  end

  it "should return all available posts" do
    index = FluffyBarbarian::Index.new(File.join(FIXTURES, "content/_posts"))

    index.all.collect{|f| f[:title]}.should ==
      ["I'm içi, todo bem?", "Mmm pie"]

    index.all.first[:extname].should == ".mkd"
  end
end
