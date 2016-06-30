#!/opt/puppetlabs/puppet/bin/ruby
require 'puppetclassify'
require 'getoptlong'
require 'puppet'
require 'hiera'
require 'facter'
require 'r10k/action/deploy/environment'
require 'r10k/action/runner'

private_key = <<-EOS
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEApjhnxCSNWVJJGoRKvrV00cMB8utFSxIlG87Hid2ViTQMgRAj
bDXWAlj9lMyiwU5XRUrCAjRJuw+oOcYxl6MQap8rgalc42DBmixbmlWFa/CV+qEn
D/RDY7jm0esAbuyybtkaIn4IIWSfNuiKi18UqCn54189fBWxzH6DgNnoawcqQya0
IFSoEqf+YZqr+KRJa4EJoDridgRzMaE7CHcT3HThGbYahJM/rLqb569RALHamZCC
q1zCYeUC+tkgtItvX1MiPuDwfb9DpDyS+Ktm/Jry2fQ6a5K0pWpulmBtlUH/b7IS
18RqPQ9zk8Y7k6k2ydv+OG3wb/gHVLT8oZR+tQIDAQABAoIBADpda/Ivc4J9pjWt
ZiF4zcAp3TFS803c3TLadK4wJCW9JPbcl9OTQ8YnQUNSZ4PA4lvuWBk2Cv2oDcXb
leZM16LYqQoqUfd1LgXYtYGHrgWswLz0gSbU+iS19DaZcdmBO1Y43ThnUKuJDW7W
UG+Hv1UdCCWSd6BubbQEaGCCI14Q4OeenmGbIzwBzjnlH2Xmteur0wYjmGT5nxoJ
42qD7Rm2OPsy6y5NDTJejMJDXASVBj1wQtmNTlnhGfzn4etNslav+srFhvwsqxFc
v43HGKb9VIzCW8IMVn51wXPb4b5sV6UBy7XdEyWrjjTrOpA5dXi2dQtRMP9qBiqJ
jks7vrECgYEA2m+1z3dCFkZgBiLyBIob+cF0GfBMxeKyYfiK5Y8/z6qTdFCAjVtD
q2q9GG0gBUJtvAb7AMlwsj+ozwTY7Dn9zFpjWn1PuIEerG7D4wtFMn9km/TD5YAc
51woUqMZIkLCqp/OkrrhRu+XjC0+DhWU48V4VIk1XRPCy78h+My9Q7cCgYEAws35
FLdiWJUXZaAeKQW3CV/lhm0nODPksGXi4J2q4Ljw7MrbU5EULd+Ek4ietiPM1P04
Ggwa4GVYU9gTtVsCEjeBc7ZZntk12N247tH1azL3d9huC6BNFGh+URBG1NdvjkoF
ZnxIie4fWmyF9WLNMmAlY81SVjZlI9w9s7msiPMCgYAl05SDcd6C5vr39RM+EACa
NpL5bvCMkB5d8uFysWTWfG5+hPZOBFDqnVhTo4oY/xDrr7XFxBx88aM0/lzmQ4Cc
48YyxGKKy+lY6PGJHsmD3iW5ECDgXFglBIODE/VlRnRZgcUPCce7NgBjaO5HGBup
eefFk+Em1iY0jEvAvwvDbwKBgBTd00xwyEwMzFDKcfCa+Bw89W0MzCKtDFYI0+CT
gvZHWSdEI3I0HCE9zAmxnK6N7ybxaM0Bdu+Ka4evoYzPjs08vNUUN01Ynvf36BNM
0ikFcJSZzk/Yf+kruDwerjemTADF1QZBUdPUee9JqJ+8UZaPzfF+0M8DTJomwUU7
IkwZAoGBAJhZYyuXhdJu4hO7KgvUAH29FibTmRceVHWqjH1TYVCDrmWvRQcRp0Mq
C4pqyV/fLR0ijCluO9/bDFWf1NKf3OFqFPpu84D0yVgKxINyVP32GWx6yP2keHsz
YUl+N0ChGemstrmAyRglzZUINLTLfjKRcZzFIoSEuaSRoqSSJB2R
-----END RSA PRIVATE KEY-----
EOS

public_key = <<-EOS
-----BEGIN CERTIFICATE-----
MIIC2TCCAcGgAwIBAgIBATANBgkqhkiG9w0BAQUFADAAMCAXDTE2MDYyNjIzNTEz
NloYDzIwNjYwNjE0MjM1MTM2WjAAMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEApjhnxCSNWVJJGoRKvrV00cMB8utFSxIlG87Hid2ViTQMgRAjbDXWAlj9
lMyiwU5XRUrCAjRJuw+oOcYxl6MQap8rgalc42DBmixbmlWFa/CV+qEnD/RDY7jm
0esAbuyybtkaIn4IIWSfNuiKi18UqCn54189fBWxzH6DgNnoawcqQya0IFSoEqf+
YZqr+KRJa4EJoDridgRzMaE7CHcT3HThGbYahJM/rLqb569RALHamZCCq1zCYeUC
+tkgtItvX1MiPuDwfb9DpDyS+Ktm/Jry2fQ6a5K0pWpulmBtlUH/b7IS18RqPQ9z
k8Y7k6k2ydv+OG3wb/gHVLT8oZR+tQIDAQABo1wwWjAPBgNVHRMBAf8EBTADAQH/
MB0GA1UdDgQWBBTt2IMiH/4qn1Pz2PHPaB7o+VJdLTAoBgNVHSMEITAfgBTt2IMi
H/4qn1Pz2PHPaB7o+VJdLaEEpAIwAIIBATANBgkqhkiG9w0BAQUFAAOCAQEATtHc
Twa0D+v8nb+eta3cs+BdGsW7uZvOcwlVbD0JWtE45EaGHs448y+99e+5UeQi+Kp1
rRtVD+So2606BY29fyndE+BOgFndGZRznWeiBBUZ1mO/WRyJZEyLEHA9CBJLdZZ3
USQ+QkGQP2Zs1Lmx1sHOL2puiLZlNWhq5o8NJ5/13g7gwte4hYeXvrzID1I3cUrb
dwMPt6oidmx47ZSTNkocl00+1SSdt74yB+FFbvSoaiE5L4fzoFsYd7LYKmen9TsH
CVm0Fnw2jKopBx8QgdMRlaz6gAuIFaWMCSXLh2tzokJxzcIreKjkKbe6pSbLDLGk
niYGTE2SC9pmrPAurw==
-----END CERTIFICATE-----
EOS

hiera_config = <<-EOS
---
:backends:
  - yaml
  - json
  - eyaml
:hierarchy:
  - "%{::trusted.certname}"
  - common

:yaml:
  :datadir: /etc/puppetlabs/code/environments/%{environment}/hieradata
:json:
  :datadir: /etc/puppetlabs/code/environments/%{environment}/hieradata
:eyaml:
  :datadir: /etc/puppetlabs/code/environments/%{environment}/hieradata
  :pkcs7_private_key: /etc/puppetlabs/puppet/ssl/private_key.pkcs7.pem
  :pkcs7_public_key: /etc/puppetlabs/puppet/ssl/public_key.pkcs7.pem
EOS

def cputs(string)
  puts "\033[1m#{string}\033[0m"
end

# Have puppet parse its config so we can call its settings
Puppet.initialize_settings

def config_r10k(remote)
  cputs "Configuring r10k"
  load_classifier
  conf = Puppet::Resource.new("file",'/etc/puppetlabs/r10k/r10k.yaml', :parameters => {
    :ensure => 'file',
    :owner  => 'root',
    :group  => 'root',
    :mode   => '0644',
    :content => "cachedir: '/var/cache/r10k'\n\nsources:\n  code:\n    remote: '#{remote}'\n    basedir: '/etc/puppetlabs/code/environments'"
  })
  result, report = Puppet::Resource.indirection.save(conf)
  puts report.logs

  options = {
    :puppetfile => true,
    :config     => '/etc/puppetlabs/r10k/r10k.yaml',
    :loglevel   => 'info'
  }
  my_action = R10K::Action::Deploy::Environment

  runner = R10K::Action::Runner.new(options, [], my_action)
  runner.call
  cputs "Finished r10k"
  @classifier.update_classes.update
end

# Read classifier.yaml for split installation compatibility
def load_classifier_config
  configfile = File.join Puppet.settings[:confdir], 'classifier.yaml'
  if File.exist?(configfile)
    classifier_yaml = YAML.load_file(configfile)
    @classifier_url = "https://#{classifier_yaml['server']}:#{classifier_yaml['port']}/classifier-api"
  else
    Puppet.debug "Config file #{configfile} not found"
    puts "no config file! - wanted #{configfile}"
    exit 2
  end
end

# Create classifier instance var
# Uses the local hostcertificate for auth ( assume we are
# running from master in whitelist entry of classifier ).
def load_classifier()
  auth_info = {
    'ca_certificate_path' => Puppet[:localcacert],
    'certificate_path'    => Puppet[:hostcert],
    'private_key_path'    => Puppet[:hostprivkey],
  }
  unless @classifier
    load_classifier_config
    @classifier = PuppetClassify.new(@classifier_url, auth_info)
  end
end

# Add parent group as PE Infrasture so we can steal the params
# from there that the default install lays down
def create_group(group_name,group_uuid,classes = {},rule_term,parent_group)
  load_classifier
  groups = @classifier.groups
  @classifier.update_classes.update
  current_group = groups.get_groups.select { |group| group['name'] == group_name}
  if current_group.empty?
    cputs "Creating #{group_name} group in classifier"
    groups.create_group({
      'name'    => group_name,
      'id'      => group_uuid,
      'classes' => classes,
      'parent'  => groups.get_group_id("#{parent_group}"),
      'rule'    => rule_term
    })
  else
    cputs "NODE GROUP #{group_name} ALREADY EXISTS!!! Skipping"
  end
end

def new_groups()
  cputs = "Making New Node Groups"
  web_group = {
    'role::web_server' => {}
  }

  app_group = {
    'role::app_server' => {}
  }

  db_group = {
    'role::db_server' => {}
  }
  #Web Group
  create_group("ウェブ・グループ",'937f05eb-8185-4517-a609-3e64d05191c2',web_group,["or",["=",["trusted","extensions","pp_role"],"ウェブ_サーバ"],["~",["fact","pp_role"],"ウェブ_サーバ"]],"All Nodes")
  #Application Group
  create_group("アプリケーション・グループ",'937f05eb-8185-4517-a609-3e64d05191c1',app_group,["or",["=",["trusted","extensions","pp_role"],"アプリ_サーバ"],["~",["fact","pp_role"],"アプリ_サーバ"]],'All Nodes')
  #Databse Group
  create_group("データベース・グループ",'937f05eb-8185-4517-a609-3e64d05191ca',db_group,["and",["=",["trusted","extensions","pp_role"],"db_サーバ"],["~",["fact","pp_role"],"db_サーバ"]],'All Nodes')
end

def change_classification()
  cputs "Update Node Groups"
  master_rule = ["and",["=","name","master.puppet.vm"]]
  master_classes = {
    'pe_repo' => {},
    'pe_repo::platform::el_7_x86_64' => {},
    'pe_repo::platform::windows_x86_64' => {},
    'puppet_enterprise::profile::master' => {},
    'puppet_enterprise::profile::master::mcollective' => {},
    'puppet_enterprise::profile::mcollective::peadmin' => {}
  }

  update_node_group(
    "PE Master",
    master_rule,
    master_classes
  )

end

def update_node_group(node_group,rule,classes)
  cputs "Update Node Group #{node_group}"
  load_classifier
  groups = @classifier.groups
  pe_group = groups.get_groups.select { |group| group['name'] == "#{node_group}"}

  if classes
    group_hash = pe_group.first.merge({"classes" => classes})
    groups.update_group(group_hash)
  end
  group_hash = pe_group.first.merge({ "rule" => rule})

  groups.update_group(group_hash)
end

def resource_manage(resource_type, resource_name, cmd_hash)
  begin
    cputs "Managing reosurce #{resource_name}"
    x = ::Puppet::Resource.new(resource_type, resource_name, :parameters => cmd_hash)
    result, report = ::Puppet::Resource.indirection.save(x)
    report.finalize_report
    if report.exit_status == 4
      raise "ERROR: Could not manage resource of #{resource_type} with the title #{resource_name}: #{report.exit_status}"
    end
  end
end

#config_r10k('https://github.com/beergeek/utf_8_test.git')
new_groups()
change_classification()
resource_manage('file','/etc/puppetlabs/puppet/ssl/private_key.pkcs7.pem',{'ensure' => 'file','owner' => 'pe-puppet','group' => 'pe-puppet', 'mode' => '0400','content' => "#{private_key}" })
resource_manage('file','/etc/puppetlabs/puppet/ssl/public_key.pkcs7.pem',{'ensure' => 'file','owner' => 'pe-puppet','group' => 'pe-puppet', 'mode' => '0644','content' => "#{public_key}" })
resource_manage('file','/etc/puppetlabs/puppet/hiera.yaml',{'ensure' => 'file','owner' => 'root','group' => 'root', 'mode' => '0644','content' => "#{hiera_config}" })
