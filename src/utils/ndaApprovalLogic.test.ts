import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import {
  computeSessionSeal,
  createPendingTesterDossier,
  evaluatePasscodeUnlockAttempt,
  generateUniqueTesterPasscode,
  getTesterVisiblePasscode,
  updateTesterApprovalStatus,
  verifyFounderAdminCredentials,
  verifySessionSeal,
  verifyStudioMasterSecret,
} from './ndaApprovalLogic';

describe('NDA Manual Founder Approval & Founder Admin Login Gate', () => {
  it('authenticates Founder Admin Login exclusively with username admin88 and password Cg0167853!8808', () => {
    assert.equal(
      verifyFounderAdminCredentials('admin88', 'Cg0167853!8808'),
      true
    );
    assert.equal(
      verifyFounderAdminCredentials('ADMIN88', 'Cg0167853!8808'),
      true
    );
    // Rejects wrong password case or wrong username
    assert.equal(
      verifyFounderAdminCredentials('admin88', 'cg0167853!8808'),
      false
    );
    assert.equal(
      verifyFounderAdminCredentials('admin99', 'Cg0167853!8808'),
      false
    );
    assert.equal(verifyFounderAdminCredentials('', ''), false);
  });

  it('hides the generated ALI-XX-XXXX passcode while approval_status is pending', () => {
    const dossier = createPendingTesterDossier({
      fullName: 'Jordan Peele',
      email: 'jordan@monkeypaw.com',
      phone: '555-234-5678',
      signature: 'Jordan Peele',
      deviceFingerprint: 'DEV-WEB-A1B2C3D4',
      deviceModel: 'Galaxy S26 Ultra',
      osVersion: 'Android 16',
      networkConnection: 'Both Tested',
      agreedIp: true,
      agreedConfidential: true,
      interestedInPartnership: true,
      selectedTracks: ["4. Senior Creative Director & Writer's Room Lead"],
      backgroundSummary: 'Writer & Director',
    });

    assert.equal(dossier.approval_status, 'pending');
    assert.match(dossier.unique_passcode, /^ALI-JP-[A-Z0-9]{4}$/);
    assert.equal(getTesterVisiblePasscode(dossier), null);
  });

  it('blocks Step 2 unlock if a pending tester attempts to use their passcode before Founder approval', () => {
    const dossier = createPendingTesterDossier({
      fullName: 'Jordan Peele',
      email: 'jordan@monkeypaw.com',
      phone: '555-234-5678',
      signature: 'Jordan Peele',
      deviceFingerprint: 'DEV-WEB-A1B2C3D4',
      deviceModel: 'Galaxy S26 Ultra',
      osVersion: 'Android 16',
      networkConnection: 'Both Tested',
      agreedIp: true,
      agreedConfidential: true,
      interestedInPartnership: false,
      selectedTracks: [],
      backgroundSummary: '',
    });

    const registry = { [dossier.unique_passcode]: dossier };

    const attempt = evaluatePasscodeUnlockAttempt({
      enteredCode: dossier.unique_passcode,
      currentDeviceFingerprint: 'DEV-WEB-A1B2C3D4',
      registry,
    });

    assert.equal(attempt.unlocked, false);
    assert.equal(attempt.status, 'pending_approval');
  });

  it('reveals the passcode and allows Step 2 unlock on the bound device once the Founder approves the tester', () => {
    const dossier = createPendingTesterDossier({
      fullName: 'Issa Rae',
      email: 'issa@hoorae.com',
      phone: '555-876-5432',
      signature: 'Issa Rae',
      deviceFingerprint: 'DEV-WEB-99887766',
      deviceModel: 'iPhone 16 Pro Max',
      osVersion: 'iOS 18',
      networkConnection: 'Wi-Fi',
      agreedIp: true,
      agreedConfidential: true,
      interestedInPartnership: true,
      selectedTracks: [
        '1. Co-Founder & Chief Operating Officer (COO) / Studio Head',
      ],
      backgroundSummary: 'Producer & Studio Founder',
    });

    let registry: Record<string, typeof dossier> = {
      [dossier.unique_passcode]: dossier,
    };

    registry = updateTesterApprovalStatus(
      registry,
      dossier.unique_passcode,
      'approved',
      'Founder (Corey Geter · admin88)'
    );

    const updated = registry[dossier.unique_passcode];
    assert.equal(updated.approval_status, 'approved');
    assert.equal(getTesterVisiblePasscode(updated), dossier.unique_passcode);

    const unlockResult = evaluatePasscodeUnlockAttempt({
      enteredCode: dossier.unique_passcode,
      currentDeviceFingerprint: 'DEV-WEB-99887766',
      registry,
    });

    assert.equal(unlockResult.unlocked, true);
    assert.equal(unlockResult.status, 'unlocked_tester');
  });

  it('triggers NDA_BREACH alert if an approved tester shares their passcode with a different device', () => {
    const dossier = createPendingTesterDossier({
      fullName: 'Donald Glover',
      email: 'donald@gilga.com',
      phone: '555-333-4444',
      signature: 'Donald Glover',
      deviceFingerprint: 'DEV-WEB-ORIGINAL',
      deviceModel: 'Galaxy S26 Ultra',
      osVersion: 'Android 16',
      networkConnection: '5G / Cellular',
      agreedIp: true,
      agreedConfidential: true,
      interestedInPartnership: false,
      selectedTracks: [],
      backgroundSummary: '',
    });

    const registry = updateTesterApprovalStatus(
      { [dossier.unique_passcode]: dossier },
      dossier.unique_passcode,
      'approved'
    );

    const breachAttempt = evaluatePasscodeUnlockAttempt({
      enteredCode: dossier.unique_passcode,
      currentDeviceFingerprint: 'DEV-WEB-SECOND-DEVICE',
      registry,
    });

    assert.equal(breachAttempt.unlocked, false);
    assert.equal(breachAttempt.status, 'breach_detected');
  });

  it('verifies Studio Master Secret and Founder password', () => {
    assert.equal(verifyStudioMasterSecret('admin3888'), true);
    assert.equal(verifyStudioMasterSecret('Cg0167853!8808'), true);
    assert.equal(verifyStudioMasterSecret('wrong1234'), false);
    assert.equal(
      generateUniqueTesterPasscode(
        'Corey Geter',
        'getercorey97@gmail.com',
        '5551234567',
        'DEV-1'
      ),
      generateUniqueTesterPasscode(
        'Corey Geter',
        'getercorey97@gmail.com',
        '5551234567',
        'DEV-1'
      )
    );
  });

  it('generates and verifies tamper-proof cryptographic hardware seals for offline and persistence protection', () => {
    const seal = computeSessionSeal(
      'ALI-CG-7K9M',
      'DEV-AND-99001122',
      'approved'
    );
    assert.match(seal, /^SEAL-[0-9A-F]+-[0-9A-F]+$/);

    // Valid on matching hardware device and status
    assert.equal(
      verifySessionSeal(seal, 'ALI-CG-7K9M', 'DEV-AND-99001122', 'approved'),
      true
    );

    // Rejects forged / mismatched hardware device fingerprint
    assert.equal(
      verifySessionSeal(seal, 'ALI-CG-7K9M', 'DEV-AND-SECOND-DEVICE', 'approved'),
      false
    );

    // Rejects forged / altered status (e.g., trying to self-promote from pending)
    assert.equal(
      verifySessionSeal(seal, 'ALI-CG-7K9M', 'DEV-AND-99001122', 'pending'),
      false
    );

    // Rejects forged / wrong passcode
    assert.equal(
      verifySessionSeal(seal, 'ALI-XX-FAKE', 'DEV-AND-99001122', 'approved'),
      false
    );

    // Rejects null, empty or missing seal
    assert.equal(
      verifySessionSeal(null, 'ALI-CG-7K9M', 'DEV-AND-99001122', 'approved'),
      false
    );
  });
});

