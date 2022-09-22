# Effective Identity Verification (IDV)

Users complete a wizard and upload encrypted identity documents like drivers licenses.

An admin views the documents and verifies the user identity.

## Getting Started

This requires Rails 6+ and Twitter Bootstrap 4 and just works with Devise.

Please first install the [effective_datatables](https://github.com/code-and-effect/effective_datatables) gem.

Please download and install the [Twitter Bootstrap4](http://getbootstrap.com)

Add to your Gemfile:

```ruby
gem 'haml-rails' # or try using gem 'hamlit-rails'
gem 'effective_idv'
```

Run the bundle command to install it:

```console
bundle install
```

Then run the generator:

```ruby
rails generate effective_idv:install
```

The generator will install an initializer which describes all configuration options and creates a database migration.

If you want to tweak the table names, manually adjust both the configuration file and the migration now.

Then migrate the database:

```ruby
rake db:migrate
```

Please add the following to your User model:

```
effective_idv_user
```

and

```
Add a link to the admin menu:

```haml
- if can? :admin, :effective_idv
  = nav_link_to 'Identity Verifications', effective_idv.admin_identity_verifications_path
```

## Configuration

## Authorization

All authorization checks are handled via the effective_resources gem found in the `config/initializers/effective_resources.rb` file.

## Effective Roles

This gem works with effective roles for the representative roles.

Configure your `config/initializers/effective_roles.rb` something like this:

```


```

## Permissions

The permissions you actually want to define are as follows (using CanCan):

```ruby
if user.persisted?
  can([:index, :show], EffectiveIdv.IdentityVerification) { |idv| idv.user == user }
  can([:update, :destroy], EffectiveIdv.IdentityVerification) { |idv| idv.user == user && !idv.was_submitted? }
end

if user.admin?
  can :admin, :effective_idv

  can(crud - [:destroy], EffectiveIdv.IdentityVerification)
  can(:destroy, EffectiveIdv.IdentityVerification) { |idv| idv.draft? }

  can(:approve, EffectiveIdv.IdentityVerification) { |idv| idv.was_submitted? && !idv.approved? }
  can(:decline, EffectiveIdv.IdentityVerification) { |idv| idv.was_submitted? && !idv.declined? }
end
```

## License

MIT License.  Copyright [Code and Effect Inc.](http://www.codeandeffect.com/)

## Testing

Run tests by:

```ruby
rails test
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Bonus points for test coverage
6. Create new Pull Request
