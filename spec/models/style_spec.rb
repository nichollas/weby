require 'spec_helper'

describe Style do
  pending { expect(subject).to belong_to(:owner).class_name('Site') }
  pending { expect(subject).to belong_to(:owner).class_name('Site') }

  pending { expect(subject).to have_many(:sites_styles).dependent(:destroy) }
  pending { expect(subject).to have_many(:followers).through(:sites_styles) }

  pending { expect(subject).to accept_nested_attributes_for(:sites_styles) }

  pending { expect(subject).to validate_presence_of(:name) }
  pending { expect(subject).to validate_presence_of(:owner) }

  pending 'should publish is default true' do
    subject = Style.new

    expect(subject.publish).to eq true
  end

  context 'scopes' do
    before do
      create_objects!
    end

    pending 'by_name' do
      pending 'Escrever em integration'
      subject = Style.by_name @style_1.name

      expect(subject).to eq [@style_1]
      expect(subject).to_not eq [@style_2]
      expect(subject).to_not eq [@style_1, @style_2]
    end

    pending 'not_followed_by' do
      pending 'Escrever em integration'
    end
  end

  def create_objects!
    @locale = create(:locale)
    @site_1 = create(:site, locales: [@locale])
    @site_2 = create(:site, locales: [@locale])
    @style_1 = create(:style, owner: @site_1)
    @style_2 = create(:style, owner: @site_2)
  end
end
