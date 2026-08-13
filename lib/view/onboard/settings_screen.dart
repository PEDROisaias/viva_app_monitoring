import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viva_app_monitoring/models/mqtt_broker_config.dart';

import '../../view_model/settings_view_model.dart';
import '../../res/style/app_theme.dart';

class SettingsScreen extends StatefulWidget{
  const SettingsScreen({super.key});
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _hostCtrl;
  late TextEditingController _portCtrl;
  late TextEditingController _clientIdCtrl;
  late TextEditingController _topicPrefixCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _passwordCtrl;
  bool _useSsl = false;
  bool _useWebSocket = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<SettingsViewModel>();
    final cfg = vm.config;
    _hostCtrl = TextEditingController(text: cfg.host);
    _portCtrl = TextEditingController(text: cfg.port.toString());
    _clientIdCtrl = TextEditingController(text: cfg.clientId);
    _topicPrefixCtrl = TextEditingController(text: cfg.topicPrefix);
    _usernameCtrl = TextEditingController(text: cfg.username ?? '');
    _passwordCtrl = TextEditingController(text: cfg.password ?? '');
    _useSsl = cfg.useSsl;
    _useWebSocket = cfg.useWebSocket;
  }

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _clientIdCtrl.dispose();
    _topicPrefixCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  MqttBrokerConfig _buildConfig() => MqttBrokerConfig(
    host: _hostCtrl.text.trim(),
    port: int.tryParse(_portCtrl.text) ?? 1883,
    clientId: _clientIdCtrl.text.trim(),
    topicPrefix: _topicPrefixCtrl.text.trim(),
    username: _usernameCtrl.text.trim().isNotEmpty ? _usernameCtrl.text.trim() : null,
    password: _passwordCtrl.text.trim().isNotEmpty ? _passwordCtrl.text.trim() : null,
    useSsl: _useSsl,
    useWebSocket: _useWebSocket,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AM032Colors.bgPrimary,
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: AM032Colors.bgPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Consumer<SettingsViewModel>(
        builder: (context, vm, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _SectionHeader(title: 'Broker MQTT', icon: Icons.router_outlined),
                const SizedBox(height: 12),

                _AM032TextField(
                  controller: _hostCtrl,
                  label: 'Server URI / Host',
                  hint: 'broker.hivemq.com',
                  prefixIcon: Icons.dns_outlined,
                  validator: (v) => 
                    (v?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                  
                ),
                const SizedBox(height: 12),

                _AM032TextField(
                  controller: _portCtrl,
                  label: 'Porta',
                  hint: '1883',
                  prefixIcon: Icons.electrical_services_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1 || n > 65535) return 'Porta inválida';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                _AM032TextField(
                  controller: _topicPrefixCtrl,
                  label: 'Topic Prefix',
                  hint: 'am032',
                  prefixIcon: Icons.topic_outlined,
                ),

                const SizedBox(height: 12),

                _AM032TextField(
                  controller: _clientIdCtrl,
                  label: 'Client ID',
                  hint: 'am032_app_unique',
                  prefixIcon: Icons.badge_outlined,
                  validator: (v) => 
                    (v?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                ),

                const SizedBox(height: 20),

                _SectionHeader(title: 'Credenciais', icon: Icons.lock_outline),
                const SizedBox(height: 12),

                _AM032TextField(
                  controller: _usernameCtrl,
                  label: 'Usuário (opcional)',
                  hint: 'usuário',
                  prefixIcon: Icons.person_outline,
                ),

                const SizedBox(height: 12),

                _AM032TextField(
                  controller: _passwordCtrl,
                  label: 'Senha (opcional)',
                  hint: '••••••••',
                  prefixIcon: Icons.key_outlined,
                  obscureText: !_showPassword,
                  suffix: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: AM032Colors.textMuted,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),

                const SizedBox(height: 20),

                _SectionHeader(title: 'Avançado', icon: Icons.tune),

                const SizedBox(height: 4),

                _AM032Toggle(
                  label: 'Usar SSL / TLS',
                  subtitle: 'Porta padrão: 8883',
                  value: _useSsl,
                  onChanged: (v) => setState(() {
                    _useSsl = v;
                    if (v && _portCtrl.text == '1883') {
                      _portCtrl.text = '8883';
                    }
                  }),
                ),

                _AM032Toggle(
                  label: 'WebSockets',
                  subtitle: 'Porta padrão: 8083',
                  value: _useWebSocket,
                  onChanged: (v) => setState(() {
                    _useWebSocket = v;
                    if (v && _portCtrl.text == '1883') {
                      _portCtrl.text = '8083';
                    }
                  }),
                ),

                const SizedBox(height: 24),

                if (vm.testResult != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: vm.testResult!.contains('✅') 
                        ? AM032Colors.statusGood.withValues(alpha: 0.1)
                        : AM032Colors.statusDanger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: vm.testResult!.contains('✅')
                          ? AM032Colors.statusGood.withValues(alpha: 0.4)
                          : AM032Colors.statusDanger.withValues(alpha: 0.4),
                      ),
                    ),

                    child: Text(
                      vm.testResult!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],

                OutlinedButton.icon(
                  onPressed: vm.isTesting
                    ? null
                    : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        vm.updateConfig(_buildConfig());
                        vm.testConnection();
                      }
                    },
                  icon: vm.isTesting
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ) 

                    : const Icon(Icons.wifi_tethering),
                  label: Text(vm.isTesting ? 'Testando...' : 'Testar Conexão'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AM032Colors.accentBlue,
                    side: const BorderSide(color: AM032Colors.accentBlue),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      vm.updateConfig(_buildConfig());
                      vm.saveAndApply().then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Configurações salvas e aplicadas'),
                            backgroundColor: AM032Colors.statusGood,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      });
                    }
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar e Conectar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AM032Colors.accentBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AM032Colors.accentBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}

class _AM032TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _AM032TextField({
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AM032Colors.textMuted, fontSize: 13),
        labelStyle: const TextStyle(color: AM032Colors.textSecondary, fontSize: 13),
        prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 18, color: AM032Colors.textMuted)
          : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: AM032Colors.bgElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AM032Colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AM032Colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AM032Colors.accentBlue, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AM032Colors.statusDanger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _AM032Toggle extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AM032Toggle({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AM032Colors.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AM032Colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14)),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
              ],
            ),
          ),

          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AM032Colors.accentBlue,
          ),
        ],
      ),
    );
  }
}