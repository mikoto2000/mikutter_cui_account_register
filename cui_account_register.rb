Plugin.create(:cui_account_register) do
  on_boot do
    # token がなければ access token の取得を行う
    unless File.exist?(Environment::SETTINGDIR + "/core/token")

      # MikuTwitter 準備
      tw = MikuTwitter.new
      tw.consumer_key = Environment::TWITTER_CONSUMER_KEY
      tw.consumer_secret = Environment::TWITTER_CONSUMER_SECRET

      # アカウント登録開始
      begin
        puts "Twitter アカウントの登録を開始します。"
        reqt = tw.request_oauth_token
        puts "■ 登録方法"
        puts "  1. #{reqt.authorize_url} にアクセスする"
        puts "  2. mikutterに 登録したい Twitter アカウントでログイン"
        puts "  3. ログイン後に取得できる PIN コード(7 桁のコード) 下記に入力"
        print "PIN : "
        STDOUT.flush
        access_token = reqt.get_access_token(oauth_token: reqt.token, oauth_verifier: gets.chomp)
        Service.add_service(access_token.token, access_token.secret)
        puts "登録に成功しました！"
      rescue Net::HTTPResponse => e
        puts "Failed: Network error(#{e})"
        raise e
      rescue OAuth::Unauthorized => e
        puts "たぶん PIN コードを間違えています。もう一回、最初から試してみてください。"
        raise e
      end
    end
  end
end
