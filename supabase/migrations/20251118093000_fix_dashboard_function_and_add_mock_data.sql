-- Location: supabase/migrations/20251118093000_fix_dashboard_function_and_add_mock_data.sql
-- Schema Analysis: Existing Vekariya Brothers system with complete schema
-- Integration Type: Enhancement with mock data and function fixes
-- Dependencies: Existing karigars, daily_work_entries, upad_payments, user_profiles tables

-- Update the get_dashboard_statistics function to return all expected fields
CREATE OR REPLACE FUNCTION public.get_dashboard_statistics()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_build_object(
        -- Basic counts
        'total_karigars', (SELECT COUNT(*) FROM public.karigars WHERE is_active = true),
        'active_karigars', (SELECT COUNT(DISTINCT k.id) FROM public.karigars k 
                           JOIN public.machine_assignments ma ON k.id = ma.karigar_id 
                           WHERE k.is_active = true AND ma.is_active = true),
        'total_machines', (SELECT COUNT(*) FROM public.machines WHERE is_active = true),
        'assigned_machines', (SELECT COUNT(*) FROM public.machines WHERE status = 'assigned'),
        
        -- Today's stats
        'todays_work_entries', (SELECT COUNT(*) FROM public.daily_work_entries 
                               WHERE work_date = CURRENT_DATE),
        'todays_pieces', (SELECT COALESCE(SUM(pieces_completed), 0) 
                         FROM public.daily_work_entries 
                         WHERE work_date = CURRENT_DATE),
        'todays_earnings', (SELECT COALESCE(SUM(total_amount), 0) 
                           FROM public.daily_work_entries 
                           WHERE work_date = CURRENT_DATE),
        
        -- Monthly stats  
        'monthly_earnings', (SELECT COALESCE(SUM(total_amount), 0) 
                            FROM public.daily_work_entries 
                            WHERE DATE_TRUNC('month', work_date) = DATE_TRUNC('month', CURRENT_DATE)),
        'monthly_upad', (SELECT COALESCE(SUM(amount), 0) 
                        FROM public.upad_payments 
                        WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE)),
        
        -- Pending payments
        'pending_upads', (SELECT COALESCE(SUM(amount), 0) 
                         FROM public.upad_payments 
                         WHERE status = 'pending'),
        'pending_upads_count', (SELECT COUNT(*) FROM public.upad_payments WHERE status = 'pending')
    ) INTO result;
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in get_dashboard_statistics: %', SQLERRM;
        -- Return default values on error
        RETURN jsonb_build_object(
            'total_karigars', 0,
            'active_karigars', 0,
            'total_machines', 0,
            'assigned_machines', 0,
            'todays_work_entries', 0,
            'todays_pieces', 0,
            'todays_earnings', 0,
            'monthly_earnings', 0,
            'monthly_upad', 0,
            'pending_upads', 0,
            'pending_upads_count', 0
        );
END;
$function$;

-- Add comprehensive mock data for a fully working system
DO $$
DECLARE
    admin_user_id UUID := gen_random_uuid();
    manager_user_id UUID := gen_random_uuid();
    operator_user_id UUID := gen_random_uuid();
    
    karigar1_id UUID := gen_random_uuid();
    karigar2_id UUID := gen_random_uuid();
    karigar3_id UUID := gen_random_uuid();
    karigar4_id UUID := gen_random_uuid();
    karigar5_id UUID := gen_random_uuid();
    
    machine1_id UUID := gen_random_uuid();
    machine2_id UUID := gen_random_uuid();
    machine3_id UUID := gen_random_uuid();
    machine4_id UUID := gen_random_uuid();
BEGIN
    -- Create user profiles for the system
    INSERT INTO public.user_profiles (id, email, full_name, role, phone, address, is_active) VALUES
        (admin_user_id, 'admin@vekariyabrothers.com', 'Vekariya Admin', 'admin', '+91-9876543210', 'Main Office, Surat', true),
        (manager_user_id, 'manager@vekariyabrothers.com', 'Production Manager', 'manager', '+91-9876543211', 'Factory Floor, Surat', true),
        (operator_user_id, 'operator@vekariyabrothers.com', 'Floor Operator', 'operator', '+91-9876543212', 'Production Unit, Surat', true);
    
    -- Create comprehensive karigar data
    INSERT INTO public.karigars (
        id, full_name, email, phone, address, skill_level, daily_rate, 
        emergency_contact_name, emergency_contact_phone, bank_account_number, 
        bank_ifsc_code, bank_name, profile_photo_url, aadhar_number, 
        pan_number, created_by, is_active
    ) VALUES
        (karigar1_id, 'Ramesh Kumar Patel', 'ramesh.patel@example.com', '+91-9876501234', 
         '123 Textile Colony, Ring Road, Surat - 395002', 'expert', 850.00,
         'Sunita Patel', '+91-9876501235', '1234567890123456', 'SBIN0001234', 'State Bank of India',
         'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
         '123456789012', 'ABCDE1234F', admin_user_id, true),
         
        (karigar2_id, 'Suresh Bhai Shah', 'suresh.shah@example.com', '+91-9876502345',
         '456 Weaver Street, Katargam, Surat - 395004', 'advanced', 750.00,
         'Kiran Shah', '+91-9876502346', '2345678901234567', 'HDFC0001235', 'HDFC Bank',
         'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
         '234567890123', 'BCDEF2345G', admin_user_id, true),
         
        (karigar3_id, 'Mukesh Dinesh Vora', 'mukesh.vora@example.com', '+91-9876503456',
         '789 Craftsman Lane, Varachha, Surat - 395006', 'intermediate', 650.00,
         'Asha Vora', '+91-9876503457', '3456789012345678', 'ICIC0001236', 'ICICI Bank',
         'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
         '345678901234', 'CDEFG3456H', manager_user_id, true),
         
        (karigar4_id, 'Dinesh Kumar Mehta', 'dinesh.mehta@example.com', '+91-9876504567',
         '321 Tailor Block, Adajan, Surat - 395009', 'advanced', 720.00,
         'Priya Mehta', '+91-9876504568', '4567890123456789', 'AXIS0001237', 'Axis Bank',
         'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150&h=150&fit=crop&crop=face',
         '456789012345', 'DEFGH4567I', manager_user_id, true),
         
        (karigar5_id, 'Prakash Jayesh Modi', 'prakash.modi@example.com', '+91-9876505678',
         '654 Stitching Avenue, Udhna, Surat - 395007', 'beginner', 500.00,
         'Meena Modi', '+91-9876505679', '5678901234567890', 'PUNB0001238', 'Punjab National Bank',
         'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&h=150&fit=crop&crop=face',
         '567890123456', 'EFGHI5678J', operator_user_id, true);
    
    -- Create machine data
    INSERT INTO public.machines (
        id, machine_name, machine_type, model_number, serial_number, 
        manufacturer, purchase_date, status, maintenance_schedule, 
        specifications, location, created_by, is_active
    ) VALUES
        (machine1_id, 'High-Speed Overlock M001', 'overlock', 'HL-2500X', 'SN2023001',
         'Juki Corporation', '2023-01-15', 'assigned', 'monthly',
         '{"speed": "8000 rpm", "needles": "3-4", "thread": "polyester"}',
         'Production Floor A - Station 1', admin_user_id, true),
         
        (machine2_id, 'Industrial Straight Stitch M002', 'straight_stitch', 'DDL-8700H', 'SN2023002',
         'Juki Corporation', '2023-02-20', 'assigned', 'monthly',
         '{"speed": "5500 rpm", "needles": "1", "thread": "cotton/polyester"}',
         'Production Floor A - Station 2', admin_user_id, true),
         
        (machine3_id, 'Multi-Function Embroidery M003', 'embroidery', 'PR-1000E', 'SN2023003',
         'Brother Industries', '2023-03-10', 'available', 'quarterly',
         '{"patterns": "200+", "colors": "12", "area": "360x200mm"}',
         'Production Floor B - Station 1', admin_user_id, true),
         
        (machine4_id, 'Heavy Duty Lock Stitch M004', 'lock_stitch', 'LZ-2280A', 'SN2023004',
         'Juki Corporation', '2023-01-25', 'maintenance', 'bi_monthly',
         '{"speed": "4000 rpm", "thread": "heavy duty", "fabric": "thick materials"}',
         'Production Floor B - Station 2', admin_user_id, true);
    
    -- Create machine assignments
    INSERT INTO public.machine_assignments (
        karigar_id, machine_id, assigned_date, shift, productivity_target, created_by, is_active
    ) VALUES
        (karigar1_id, machine1_id, CURRENT_DATE - INTERVAL '10 days', 'morning', 85, admin_user_id, true),
        (karigar2_id, machine2_id, CURRENT_DATE - INTERVAL '8 days', 'morning', 75, admin_user_id, true),
        (karigar4_id, machine3_id, CURRENT_DATE - INTERVAL '5 days', 'evening', 65, manager_user_id, true);
    
    -- Create comprehensive daily work entries for the last 30 days
    INSERT INTO public.daily_work_entries (
        karigar_id, machine_id, work_date, work_type, pieces_completed, 
        rate_per_piece, total_amount, quality_rating, notes, status, created_by
    ) VALUES
        -- Today's entries
        (karigar1_id, machine1_id, CURRENT_DATE, 'shirt', 45, 18.50, 832.50, 4.8, 'Excellent work quality, exceeded target', 'completed', manager_user_id),
        (karigar2_id, machine2_id, CURRENT_DATE, 'pant', 32, 22.00, 704.00, 4.6, 'Good progress, slight delay in afternoon', 'completed', manager_user_id),
        (karigar4_id, machine3_id, CURRENT_DATE, 'dress', 18, 35.00, 630.00, 4.9, 'Premium embroidery work completed', 'completed', manager_user_id),
        
        -- Yesterday's entries
        (karigar1_id, machine1_id, CURRENT_DATE - INTERVAL '1 day', 'shirt', 42, 18.50, 777.00, 4.7, 'Consistent performance', 'completed', manager_user_id),
        (karigar2_id, machine2_id, CURRENT_DATE - INTERVAL '1 day', 'pant', 35, 22.00, 770.00, 4.5, 'Completed on time', 'completed', manager_user_id),
        (karigar3_id, machine4_id, CURRENT_DATE - INTERVAL '1 day', 'jacket', 12, 45.00, 540.00, 4.4, 'Heavy fabric work completed', 'completed', operator_user_id),
        
        -- Day before yesterday
        (karigar1_id, machine1_id, CURRENT_DATE - INTERVAL '2 days', 'shirt', 48, 18.50, 888.00, 4.9, 'Outstanding productivity', 'completed', manager_user_id),
        (karigar2_id, machine2_id, CURRENT_DATE - INTERVAL '2 days', 'pant', 30, 22.00, 660.00, 4.3, 'Standard work completion', 'completed', manager_user_id),
        (karigar4_id, machine3_id, CURRENT_DATE - INTERVAL '2 days', 'dress', 20, 35.00, 700.00, 4.8, 'Intricate embroidery patterns', 'completed', manager_user_id),
        
        -- Additional entries for monthly statistics (spread across 30 days)
        (karigar1_id, machine1_id, CURRENT_DATE - INTERVAL '5 days', 'shirt', 44, 18.50, 814.00, 4.6, 'Regular production', 'completed', manager_user_id),
        (karigar2_id, machine2_id, CURRENT_DATE - INTERVAL '5 days', 'pant', 33, 22.00, 726.00, 4.4, 'Steady progress', 'completed', manager_user_id),
        (karigar3_id, machine4_id, CURRENT_DATE - INTERVAL '5 days', 'jacket', 15, 45.00, 675.00, 4.7, 'Quality work on thick fabric', 'completed', operator_user_id),
        
        (karigar1_id, machine1_id, CURRENT_DATE - INTERVAL '10 days', 'shirt', 47, 18.50, 869.50, 4.8, 'Above average performance', 'completed', manager_user_id),
        (karigar2_id, machine2_id, CURRENT_DATE - INTERVAL '10 days', 'pant', 36, 22.00, 792.00, 4.6, 'Consistent quality', 'completed', manager_user_id),
        (karigar4_id, machine3_id, CURRENT_DATE - INTERVAL '10 days', 'dress', 22, 35.00, 770.00, 4.9, 'Premium finish work', 'completed', manager_user_id),
        
        (karigar1_id, machine1_id, CURRENT_DATE - INTERVAL '15 days', 'shirt', 43, 18.50, 795.50, 4.5, 'Good daily output', 'completed', manager_user_id),
        (karigar2_id, machine2_id, CURRENT_DATE - INTERVAL '15 days', 'pant', 31, 22.00, 682.00, 4.3, 'Standard completion', 'completed', manager_user_id),
        (karigar3_id, machine4_id, CURRENT_DATE - INTERVAL '15 days', 'jacket', 13, 45.00, 585.00, 4.6, 'Heavy material processing', 'completed', operator_user_id);
    
    -- Create upad payment entries
    INSERT INTO public.upad_payments (
        karigar_id, amount, payment_type, payment_mode, reason, status, 
        payment_date, reference_number, notes, created_by
    ) VALUES
        -- Recent payments
        (karigar1_id, 5000.00, 'advance', 'bank_transfer', 'Monthly advance for family expenses', 'paid',
         CURRENT_DATE - INTERVAL '2 days', 'UPD20231116001', 'Transferred to SBI account', admin_user_id),
         
        (karigar2_id, 3500.00, 'advance', 'cash', 'Festival advance requested', 'paid',
         CURRENT_DATE - INTERVAL '5 days', 'UPD20231113002', 'Cash payment given', manager_user_id),
         
        (karigar4_id, 2500.00, 'bonus', 'bank_transfer', 'Performance bonus for quality work', 'paid',
         CURRENT_DATE - INTERVAL '7 days', 'UPD20231111003', 'Bonus for embroidery excellence', admin_user_id),
         
        (karigar3_id, 4000.00, 'advance', 'upi', 'Medical emergency advance', 'paid',
         CURRENT_DATE - INTERVAL '10 days', 'UPD20231108004', 'Emergency medical support', manager_user_id),
         
        -- Pending payments
        (karigar5_id, 2000.00, 'advance', 'bank_transfer', 'Training completion advance', 'pending',
         NULL, 'UPD20231118005', 'Pending bank account verification', operator_user_id),
         
        (karigar2_id, 1500.00, 'bonus', 'cash', 'Quality improvement bonus', 'pending',
         NULL, 'UPD20231118006', 'Awaiting cash arrangement', manager_user_id),
         
        -- Monthly payments for statistics
        (karigar1_id, 8000.00, 'full_payment', 'bank_transfer', 'October month salary settlement', 'paid',
         CURRENT_DATE - INTERVAL '20 days', 'UPD20231029007', 'Monthly salary credit', admin_user_id),
         
        (karigar2_id, 7200.00, 'full_payment', 'bank_transfer', 'October month salary settlement', 'paid',
         CURRENT_DATE - INTERVAL '20 days', 'UPD20231029008', 'Monthly salary credit', admin_user_id),
         
        (karigar3_id, 6500.00, 'full_payment', 'bank_transfer', 'October month salary settlement', 'paid',
         CURRENT_DATE - INTERVAL '20 days', 'UPD20231029009', 'Monthly salary credit', admin_user_id),
         
        (karigar4_id, 7800.00, 'full_payment', 'bank_transfer', 'October month salary settlement', 'paid',
         CURRENT_DATE - INTERVAL '20 days', 'UPD20231029010', 'Monthly salary credit', admin_user_id);
    
    -- Create activity log entries for recent activities  
    INSERT INTO public.activity_logs (
        user_id, action, entity_type, entity_id, old_data, new_data, ip_address, user_agent
    ) VALUES
        (manager_user_id, 'created', 'daily_work_entries', (SELECT id FROM public.daily_work_entries ORDER BY created_at DESC LIMIT 1), 
         NULL, jsonb_build_object('karigar_name', 'Ramesh Kumar Patel', 'pieces', 45, 'amount', 832.50), 
         '192.168.1.100', 'Mozilla/5.0 (Mobile App)'),
         
        (admin_user_id, 'created', 'upad_payments', (SELECT id FROM public.upad_payments WHERE reference_number = 'UPD20231118005'),
         NULL, jsonb_build_object('karigar_name', 'Prakash Jayesh Modi', 'amount', 2000.00, 'type', 'advance'),
         '192.168.1.101', 'Mozilla/5.0 (Mobile App)'),
         
        (manager_user_id, 'updated', 'karigars', karigar3_id,
         jsonb_build_object('skill_level', 'beginner'), jsonb_build_object('skill_level', 'intermediate'),
         '192.168.1.102', 'Mozilla/5.0 (Mobile App)'),
         
        (admin_user_id, 'created', 'karigars', karigar5_id,
         NULL, jsonb_build_object('full_name', 'Prakash Jayesh Modi', 'skill_level', 'beginner'),
         '192.168.1.103', 'Mozilla/5.0 (Mobile App)');
    
    -- Success message
    RAISE NOTICE 'Successfully added comprehensive mock data for Vekariya Brothers system';
    RAISE NOTICE 'Created: % karigars, % machines, % work entries, % upad payments', 
        (SELECT COUNT(*) FROM public.karigars WHERE created_by IN (admin_user_id, manager_user_id, operator_user_id)),
        (SELECT COUNT(*) FROM public.machines WHERE created_by = admin_user_id),
        (SELECT COUNT(*) FROM public.daily_work_entries WHERE created_by IN (admin_user_id, manager_user_id, operator_user_id)),
        (SELECT COUNT(*) FROM public.upad_payments WHERE created_by IN (admin_user_id, manager_user_id, operator_user_id));

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding mock data: %', SQLERRM;
END $$;

-- Create or update the get_sample_rows function for better data display
CREATE OR REPLACE FUNCTION public.get_sample_rows()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'karigars', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', k.id,
                    'full_name', k.full_name,
                    'skill_level', k.skill_level,
                    'daily_rate', k.daily_rate,
                    'phone', k.phone,
                    'is_active', k.is_active
                )
            )
            FROM public.karigars k 
            WHERE k.is_active = true 
            ORDER BY k.created_at DESC 
            LIMIT 5
        ),
        'recent_work', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', dwe.id,
                    'karigar_name', k.full_name,
                    'work_type', dwe.work_type,
                    'pieces_completed', dwe.pieces_completed,
                    'total_amount', dwe.total_amount,
                    'work_date', dwe.work_date,
                    'status', dwe.status
                )
            )
            FROM public.daily_work_entries dwe
            JOIN public.karigars k ON dwe.karigar_id = k.id
            ORDER BY dwe.created_at DESC 
            LIMIT 5
        ),
        'recent_payments', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', up.id,
                    'karigar_name', k.full_name,
                    'amount', up.amount,
                    'payment_type', up.payment_type,
                    'status', up.status,
                    'payment_date', up.payment_date,
                    'reason', up.reason
                )
            )
            FROM public.upad_payments up
            JOIN public.karigars k ON up.karigar_id = k.id
            ORDER BY up.created_at DESC 
            LIMIT 5
        )
    ) INTO result;
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in get_sample_rows: %', SQLERRM;
        RETURN jsonb_build_object(
            'karigars', '[]'::jsonb,
            'recent_work', '[]'::jsonb,
            'recent_payments', '[]'::jsonb
        );
END;
$function$;

-- Add helpful comments
COMMENT ON FUNCTION public.get_dashboard_statistics() IS 'Returns comprehensive dashboard statistics for Vekariya Brothers management system';
COMMENT ON FUNCTION public.get_sample_rows() IS 'Returns sample data for quick preview and testing';