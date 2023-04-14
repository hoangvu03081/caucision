RSpec.describe ProjectsController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { instance_double('Doorkeeper::AccessToken', acceptable?: true, resource_owner_id: user.id) }

  describe 'POST #import_file' do

    subject { post(:import_file, params:) }

    context 'when csv file is not provided' do
      let(:params) { { id: SecureRandom.uuid } }
      let(:expected_errors) do
        {
          errors: [
            { message: 'file: is missing', code: 'CA1001' }
          ]
        }.to_json
      end

      it { expect(subject.body).to eq(expected_errors) }
    end
  end
end
